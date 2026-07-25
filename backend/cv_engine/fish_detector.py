import logging
import time
import os
from typing import List, Dict, Any
import cv2
import torch
import numpy as np
from ultralytics import YOLO
from .config import CVEngineConfig

logger = logging.getLogger("AquariumCV")

class FishDetector:
    """
    Detects and tracks fish using a hybrid YOLOv8 + Motion Contour pipeline.
    """
    def __init__(self, config: CVEngineConfig):
        self.config = config
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        
        # Log loaded YOLO model full path and name
        model_name = config.yolo_model_path
        full_path = os.path.abspath(model_name)
        logger.info(f"[YOLO MODEL INFO] Loading model: '{model_name}' from full path: '{full_path}' on device: {self.device}")
        
        self.model = YOLO(model_name)
        
        # Print list of available class names
        class_names = list(self.model.names.values())
        logger.info(f"[YOLO MODEL CLASSES] Available classes ({len(class_names)}): {class_names}")
        
        # Check if loaded model contains a fish class
        self.has_fish_class = any("fish" in name.lower() for name in class_names)
        
        self.raw_detections: List[Dict[str, Any]] = []
        self.prev_gray = None

    def detect(self, frame: cv2.typing.MatLike) -> List[Dict[str, Any]]:
        """
        Runs YOLOv8 tracking and supplements with motion contours.
        """
        t0 = time.time()
        
        # 1. Run YOLOv8 Tracking/Detection
        results = self.model.track(
            frame,
            persist=True,
            conf=self.config.yolo_conf_threshold,
            iou=self.config.yolo_iou_threshold,
            imgsz=self.config.yolo_img_size,
            device=self.device,
            tracker=self.config.yolo_tracker,
            verbose=False
        )
        
        self.raw_detections = []
        filtered_detections = []
        
        # Parse YOLOv8 outputs
        yolo_dets = []
        if results and len(results) > 0:
            result = results[0]
            boxes = result.boxes
            if boxes is not None and len(boxes) > 0:
                for i, box in enumerate(boxes):
                    xyxy = box.xyxy[0].tolist()
                    conf = float(box.conf[0])
                    cls_id = int(box.cls[0])
                    cls_name = self.model.names[cls_id]
                    track_id = int(box.id[0]) if box.id is not None else i
                    
                    x1, y1, x2, y2 = xyxy
                    w, h = x2 - x1, y2 - y1
                    cx, cy = x1 + w/2.0, y1 + h/2.0
                    
                    yolo_dets.append({
                        "id": track_id,
                        "bbox": [int(x1), int(y1), int(x2), int(y2)],
                        "center_x": cx,
                        "center_y": cy,
                        "width": w,
                        "height": h,
                        "confidence": conf,
                        "class_name": cls_name,
                        "source": "yolo"
                    })

        # 2. Motion Contour Fallback (Frame Difference)
        motion_dets = []
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        gray = cv2.GaussianBlur(gray, (15, 15), 0)
        
        if self.prev_gray is not None:
            # Compute frame difference
            diff = cv2.absdiff(self.prev_gray, gray)
            _, thresh = cv2.threshold(diff, 15, 255, cv2.THRESH_BINARY)  # Set thresh to 15 to filter small movements
            
            # Dilate thresholded image to fill in holes
            kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (7, 7))
            thresh = cv2.dilate(thresh, kernel, iterations=2)
            
            # Find contours
            contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            for i, cnt in enumerate(contours):
                area = cv2.contourArea(cnt)
                # Fish size constraints
                if 600 < area < 25000:
                    x, y, w, h = cv2.boundingRect(cnt)
                    cx, cy = x + w/2.0, y + h/2.0
                    
                    # Filter out tiny bubbles/noise by width/height constraints
                    if w > 25 and h > 25:
                        motion_dets.append({
                            "id": 9999 + i,  # Temp ID for motion dets
                            "bbox": [int(x), int(y), int(x+w), int(y+h)],
                            "center_x": cx,
                            "center_y": cy,
                            "width": w,
                            "height": h,
                            "confidence": 0.50,  # Arbitrary moderate confidence for motion proposal
                            "class_name": "fish_motion",
                            "source": "motion"
                        })
                    
        self.prev_gray = gray

        # 3. Merge Detections using IoU Non-Maximum Suppression
        all_proposals = yolo_dets + motion_dets
        keep_indices = []
        
        # Sort proposals: YOLO first, then motion
        all_proposals.sort(key=lambda d: (0 if d["source"] == "yolo" else 1, -d["confidence"]))
        
        def compute_iou(boxA, boxB):
            xA = max(boxA[0], boxB[0])
            yA = max(boxA[1], boxB[1])
            xB = min(boxA[2], boxB[2])
            yB = min(boxA[3], boxB[3])
            interArea = max(0, xB - xA) * max(0, yB - yA)
            boxAArea = (boxA[2] - boxA[0]) * (boxA[3] - boxA[1])
            boxBArea = (boxB[2] - boxB[0]) * (boxB[3] - boxB[1])
            iou = interArea / float(boxAArea + boxBArea - interArea + 1e-6)
            return iou

        for idx, prop in enumerate(all_proposals):
            overlap = False
            for k_idx in keep_indices:
                existing = all_proposals[k_idx]
                if compute_iou(prop["bbox"], existing["bbox"]) > 0.3:  # Keep distinct proposals
                    overlap = True
                    break
            if not overlap:
                keep_indices.append(idx)
                
        final_dets = [all_proposals[idx] for idx in keep_indices]
        
        # Populate raw_detections and filtered_detections
        self.raw_detections = all_proposals
        filtered_detections = final_dets
        
        t1 = time.time()
        inference_time = t1 - t0
        det_fps = 1.0 / max(0.001, inference_time)

        # Log detailed stats for the processed frame
        logger.info(
            f"[DETECTION DEBUG] Total Detections: {len(all_proposals)} | "
            f"YOLO Detections: {len(yolo_dets)} | "
            f"Motion Detections: {len(motion_dets)} | "
            f"Filtered as Fish: {len(filtered_detections)} | "
            f"Passed to Tracker: {len(filtered_detections)}"
        )

        return filtered_detections
