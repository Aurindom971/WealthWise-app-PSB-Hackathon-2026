import tkinter as tk
from tkinter import ttk
import cv2
import PIL.Image, PIL.ImageTk
import time
import threading
from typing import Dict, Any, List

# Add parent path to import modules
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from dashboard.dashboard_server import data_provider

class DesktopMonitorApp:
    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("AQUARIUM ENTROPY GENERATION - OPERATIONS CENTER")
        self.root.geometry("1500x850")
        self.root.configure(bg="#0B0E14")

        # Set custom font style
        self.header_font = ("Consolas", 11, "bold")
        self.metric_font = ("Consolas", 10)
        self.metric_val_font = ("Consolas", 11, "bold")

        # Pipeline is started by FastAPI startup_event via main.py launcher
        # Do NOT call startup_event() here to avoid duplicate threads

        self._build_ui()
        self._update_loop()

    def _build_ui(self):
        # ── TOP BAR ──
        top_bar = tk.Frame(self.root, bg="#161B22", height=50, bd=1, relief="ridge")
        top_bar.pack(fill="x", side="top")
        
        lbl_title = tk.Label(
            top_bar, 
            text="AQUARIUM ENTROPY PIPELINE SECURE MONITOR", 
            fg="#58A6FF", bg="#161B22", 
            font=("Consolas", 14, "bold")
        )
        lbl_title.pack(side="left", padx=15)

        lbl_mode = tk.Label(
            top_bar,
            text="HACKATHON OPERATIONS MODE",
            fg="#39FF14", bg="#1f242c",
            font=("Consolas", 10, "bold"),
            padx=10, pady=4
        )
        lbl_mode.pack(side="right", padx=15)

        # ── MAIN LAYOUT FRAME ──
        main_frame = tk.Frame(self.root, bg="#0B0E14")
        main_frame.pack(fill="both", expand=True, padx=10, pady=10)

        # Left Panel (Video feed)
        self.left_frame = tk.LabelFrame(
            main_frame, text=" LIVE AQUARIUM CV FEED ", 
            fg="#58A6FF", bg="#0B0E14", bd=2, font=self.header_font
        )
        self.left_frame.pack(side="left", fill="both", expand=True, padx=5, pady=5)
        
        self.video_canvas = tk.Canvas(self.left_frame, bg="#030608", width=750, height=400)
        self.video_canvas.pack(fill="both", expand=True, padx=5, pady=5)

        # Right Container (Pipeline + CV Engine + Metrics)
        right_container = tk.Frame(main_frame, bg="#0B0E14")
        right_container.pack(side="right", fill="both", expand=True, padx=5, pady=5)

        # ─── Column 1: Pipeline Flow ───
        self.center_frame = tk.LabelFrame(
            right_container, text=" PIPELINE FLOW ", 
            fg="#58A6FF", bg="#0B0E14", bd=2, font=self.header_font
        )
        self.center_frame.pack(side="left", fill="both", expand=True, padx=3, pady=5)

        self.stages = [
            ("Fish Ingestion", "Camera feed processing"),
            ("Computer Vision", "YOLOv8 Fish/Bubble Detection"),
            ("Feature Extraction", "Motion & ripple scoring"),
            ("Entropy Collection", "Normalizing metrics"),
            ("Entropy Pool", "Entropy accumulator"),
            ("Multi-source Mixing", "5 independent inputs mixed"),
            ("SHA3-512 Conditioning", "Cryptographic conditioning"),
            ("ChaCha20 CSPRNG", "Secure seed / keystream"),
            ("Session Token Gen", "Cryptographic tokens")
        ]
        self.stage_widgets = []
        for stage_name, desc in self.stages:
            stage_box = tk.Frame(self.center_frame, bg="#161B22", bd=1, relief="solid", height=40)
            stage_box.pack(fill="x", padx=6, pady=3)
            stage_box.pack_propagate(False)

            lbl_name = tk.Label(stage_box, text=stage_name, fg="#8B949E", bg="#161B22", font=("Consolas", 9, "bold"), anchor="w")
            lbl_name.pack(fill="x", padx=8, pady=1)
            
            lbl_desc = tk.Label(stage_box, text=desc, fg="#484F58", bg="#161B22", font=("Consolas", 7), anchor="w")
            lbl_desc.pack(fill="x", padx=8)

            self.stage_widgets.append((stage_box, lbl_name, lbl_desc))

        # ─── Column 2: CV Engine Stats ───
        self.cv_frame = tk.LabelFrame(
            right_container, text=" AQUARIUM CV ENGINE ", 
            fg="#58A6FF", bg="#0B0E14", bd=2, font=self.header_font
        )
        self.cv_frame.pack(side="left", fill="both", expand=True, padx=3, pady=5)

        self.cv_labels = {}
        cv_sections = [
            ("section", "OBJECT DETECTION"),
            ("Fish Count", "0"),
            ("Avg Flow Mag", "0.0000"),
            ("Max Flow Mag", "0.0000"),
            ("Flow Direction", "0.00°"),
            ("section", "BUBBLE ANALYSIS"),
            ("Bubble Count", "0"),
            ("Avg Speed", "0.00 px/f"),
            ("Rise Velocity", "0.00 px/f"),
            ("section", "WATER SURFACE"),
            ("Ripple Intensity", "0.0000"),
            ("Ripple Frequency", "0.0000"),
            ("Water Motion", "0.0000"),
            ("section", "ENVIRONMENT"),
            ("Brightness", "0.00"),
            ("Contrast", "0.00"),
            ("Edge Density", "0.0000"),
            ("Histogram Drift", "0.0000"),
            ("Sensor Noise", "0.0000"),
        ]
        for name, default_val in cv_sections:
            if name == "section":
                # Section header
                sep = tk.Label(
                    self.cv_frame, text=f"─ {default_val} ─", 
                    fg="#00FFFF", bg="#0B0E14", 
                    font=("Consolas", 8, "bold"), anchor="w"
                )
                sep.pack(fill="x", padx=8, pady=(6, 2))
            else:
                m_row = tk.Frame(self.cv_frame, bg="#0B0E14")
                m_row.pack(fill="x", padx=8, pady=2)
                
                lbl_name = tk.Label(m_row, text=name, fg="#8B949E", bg="#0B0E14", font=("Consolas", 9), anchor="w")
                lbl_name.pack(side="left")
                
                lbl_val = tk.Label(m_row, text=default_val, fg="#39FF14", bg="#0B0E14", font=("Consolas", 9, "bold"), anchor="e")
                lbl_val.pack(side="right")
                self.cv_labels[name] = lbl_val

        # Processing FPS at bottom of CV panel
        fps_row = tk.Frame(self.cv_frame, bg="#161B22", bd=1, relief="solid")
        fps_row.pack(fill="x", padx=6, pady=(8, 4))
        tk.Label(fps_row, text="CV Processing FPS", fg="#FFD700", bg="#161B22", font=("Consolas", 9, "bold"), anchor="w").pack(side="left", padx=8, pady=3)
        self.cv_fps_label = tk.Label(fps_row, text="0.00", fg="#39FF14", bg="#161B22", font=("Consolas", 10, "bold"), anchor="e")
        self.cv_fps_label.pack(side="right", padx=8, pady=3)

        # ─── Column 3: Infrastructure Metrics ───
        self.right_frame = tk.LabelFrame(
            right_container, text=" INFRASTRUCTURE METRICS ", 
            fg="#58A6FF", bg="#0B0E14", bd=2, font=self.header_font
        )
        self.right_frame.pack(side="right", fill="both", expand=True, padx=3, pady=5)

        self.metrics_labels = {}
        metrics_list = [
            ("Entropy Pool %", "0.0%"),
            ("Pool Health", "Initializing"),
            ("Pool Size", "0.00"),
            ("Total Extracted", "0.00"),
            ("Source Count", "0"),
            ("SHA3 Status", "Healthy"),
            ("ChaCha20 Status", "Initializing"),
            ("Bytes Generated", "0"),
            ("Generation Rate", "0.0 bps"),
            ("Last Reseed", "Never"),
            ("Generator Health", "Initializing"),
            ("Token Rate", "0.00 tps"),
            ("Avg Token Time", "0.00 ms"),
        ]
        for name, default_val in metrics_list:
            m_row = tk.Frame(self.right_frame, bg="#0B0E14")
            m_row.pack(fill="x", padx=8, pady=4)
            
            lbl_name = tk.Label(m_row, text=name, fg="#8B949E", bg="#0B0E14", font=("Consolas", 9), anchor="w")
            lbl_name.pack(side="left")
            
            lbl_val = tk.Label(m_row, text=default_val, fg="#39FF14", bg="#0B0E14", font=("Consolas", 9, "bold"), anchor="e")
            lbl_val.pack(side="right")
            self.metrics_labels[name] = lbl_val

        # ── BOTTOM PANEL (Event Log + Token Details) ──
        bottom_frame = tk.Frame(self.root, bg="#0B0E14", height=200)
        bottom_frame.pack(fill="x", side="bottom", padx=15, pady=5)
        
        # Bottom Left: Event Log
        self.log_frame = tk.LabelFrame(
            bottom_frame, text=" REAL-TIME CRYPTOGRAPHIC EVENT LOG ", 
            fg="#58A6FF", bg="#0B0E14", bd=2, font=self.header_font
        )
        self.log_frame.pack(side="left", fill="both", expand=True, padx=5, pady=5)

        self.log_list = tk.Listbox(
            self.log_frame, bg="#030608", fg="#39FF14", 
            font=("Consolas", 9), bd=0, highlightthickness=0
        )
        self.log_list.pack(fill="both", expand=True, padx=5, pady=5)

        # Bottom Right: Session Token Details
        self.token_frame = tk.LabelFrame(
            bottom_frame, text=" ACTIVE SESSION TOKEN STATUS ", 
            fg="#58A6FF", bg="#0B0E14", bd=2, font=self.header_font, width=450
        )
        self.token_frame.pack(side="right", fill="both", padx=5, pady=5)
        self.token_frame.pack_propagate(False)

        self.lbl_token = tk.Label(self.token_frame, text="Token: N/A", fg="#39FF14", bg="#0B0E14", font=("Consolas", 12, "bold"), anchor="w")
        self.lbl_token.pack(fill="x", padx=15, pady=6)
        
        self.lbl_ts = tk.Label(self.token_frame, text="Timestamp: N/A", fg="#8B949E", bg="#0B0E14", font=self.metric_font, anchor="w")
        self.lbl_ts.pack(fill="x", padx=15, pady=2)

        self.lbl_count = tk.Label(self.token_frame, text="Generated Count: 0", fg="#8B949E", bg="#0B0E14", font=self.metric_font, anchor="w")
        self.lbl_count.pack(fill="x", padx=15, pady=2)

        self.lbl_gentime = tk.Label(self.token_frame, text="Generation Latency: 0.0ms", fg="#8B949E", bg="#0B0E14", font=self.metric_font, anchor="w")
        self.lbl_gentime.pack(fill="x", padx=15, pady=2)

    def _update_loop(self):
        try:
            # 1. Update Video Frame
            frame = data_provider.latest_frame
            if frame is not None:
                # Resize to fit video canvas — use canvas actual size for best fit
                h, w = frame.shape[:2]
                canvas_w = self.video_canvas.winfo_width()
                canvas_h = self.video_canvas.winfo_height()
                if canvas_w < 100:  # Fallback if canvas hasn't rendered yet
                    canvas_w = 750
                # Scale to fit canvas width while preserving aspect ratio
                target_w = canvas_w
                target_h = int((h / w) * target_w)
                # If it's taller than canvas, scale by height instead
                if target_h > canvas_h and canvas_h > 100:
                    target_h = canvas_h
                    target_w = int((w / h) * target_h)
                resized = cv2.resize(frame, (target_w, target_h))
                
                rgb = cv2.cvtColor(resized, cv2.COLOR_BGR2RGB)
                img = PIL.Image.fromarray(rgb)
                img_tk = PIL.ImageTk.PhotoImage(image=img)
                
                self.video_canvas.create_image(0, 0, anchor="nw", image=img_tk)
                self.video_canvas.image = img_tk  # Keep reference

            # 2. Update CV Engine Panel
            snap = data_provider.latest_data
            if snap:
                cv_stats = snap.get("cv_stats", {})
                entropy_stats = snap.get("entropy_stats", {})
                csprng_stats = snap.get("csprng_stats", {})
                token_stats = snap.get("token_stats", {})

                # CV Engine labels
                self.cv_labels["Fish Count"].config(text=str(cv_stats.get("fish_count", "0")))
                self.cv_labels["Avg Flow Mag"].config(text=str(cv_stats.get("motion_magnitude", "0.0000")))
                self.cv_labels["Max Flow Mag"].config(text=str(cv_stats.get("optical_flow", "0.0000")))
                self.cv_labels["Flow Direction"].config(text=f"{cv_stats.get('flow_direction', '0.00')}°")
                self.cv_labels["Bubble Count"].config(text=str(cv_stats.get("bubble_count", "0")))
                self.cv_labels["Avg Speed"].config(text=f"{cv_stats.get('avg_speed', '0.00')} px/f")
                self.cv_labels["Rise Velocity"].config(text=f"{cv_stats.get('rise_velocity', '0.00')} px/f")
                self.cv_labels["Ripple Intensity"].config(text=str(cv_stats.get("ripple_score", "0.0000")))
                self.cv_labels["Ripple Frequency"].config(text=str(cv_stats.get("ripple_frequency", "0.0000")))
                self.cv_labels["Water Motion"].config(text=str(cv_stats.get("water_motion", "0.0000")))
                self.cv_labels["Brightness"].config(text=str(cv_stats.get("brightness", "0.00")))
                self.cv_labels["Contrast"].config(text=str(cv_stats.get("contrast", "0.00")))
                self.cv_labels["Edge Density"].config(text=str(cv_stats.get("edge_density", "0.0000")))
                self.cv_labels["Histogram Drift"].config(text=str(cv_stats.get("hist_drift", "0.0000")))
                self.cv_labels["Sensor Noise"].config(text=str(cv_stats.get("noise_score", "0.0000")))
                self.cv_fps_label.config(text=str(cv_stats.get("processing_fps", "0.00")))

                # Infrastructure Metrics labels
                self.metrics_labels["Entropy Pool %"].config(text=f"{entropy_stats.get('fill_percent', '0.0')}%")
                self.metrics_labels["Pool Health"].config(text=str(entropy_stats.get("health", "Healthy")))
                self.metrics_labels["Pool Size"].config(text=str(entropy_stats.get("current_size", "0.00")))
                self.metrics_labels["Total Extracted"].config(text=str(entropy_stats.get("total_extracted", "0.00")))
                self.metrics_labels["Source Count"].config(text=str(entropy_stats.get("source_count", "0")))
                self.metrics_labels["SHA3 Status"].config(text="Healthy")
                
                reseed_c = csprng_stats.get("reseed_count", 0)
                self.metrics_labels["ChaCha20 Status"].config(text=str(csprng_stats.get("health", "Healthy")))
                self.metrics_labels["Bytes Generated"].config(text=str(csprng_stats.get("bytes_generated", 0)))
                self.metrics_labels["Generation Rate"].config(text=f"{csprng_stats.get('rate_bps', '0.0')} bps")
                self.metrics_labels["Last Reseed"].config(text=f"Reseed #{reseed_c}")
                self.metrics_labels["Generator Health"].config(text=str(token_stats.get("generator_health", "Excellent")))
                self.metrics_labels["Token Rate"].config(text=f"{token_stats.get('rate_tps', '0.00')} tps")
                self.metrics_labels["Avg Token Time"].config(text=f"{token_stats.get('avg_time_ms', '0.00')} ms")

                # Token Details
                latest_tok = token_stats.get("latest_token", "N/A")
                self.lbl_token.config(text=f"Token: {latest_tok}")
                
                # Grab latest history entry timestamp and duration
                hist = token_stats.get("history", [])
                if hist:
                    latest_entry = hist[-1]
                    self.lbl_ts.config(text=f"Timestamp: {latest_entry.get('time', 'N/A')}")
                    self.lbl_gentime.config(text=f"Generation Latency: {latest_entry.get('latency_ms', '0.0')}ms")
                self.lbl_count.config(text=f"Generated Count: {token_stats.get('total_generated', 0)}")

            # 3. Update Pipeline illumination (pulsing green highlight on active status)
            is_pipeline_active = data_provider.running
            for i, (stage_box, lbl_name, lbl_desc) in enumerate(self.stage_widgets):
                if is_pipeline_active:
                    # Alternating pulse / illuminated highlights
                    stage_box.config(bg="#1c2d20", highlightbackground="#39FF14", highlightcolor="#39FF14", highlightthickness=1)
                    lbl_name.config(fg="#39FF14", bg="#1c2d20")
                    lbl_desc.config(fg="#8B949E", bg="#1c2d20")
                else:
                    stage_box.config(bg="#161B22", highlightthickness=0)
                    lbl_name.config(fg="#8B949E", bg="#161B22")
                    lbl_desc.config(fg="#484F58", bg="#161B22")

            # 4. Update Event Log listbox
            with data_provider.lock:
                events = list(data_provider.event_log)
            
            # Repopulate log listbox if it changed
            self.log_list.delete(0, tk.END)
            for ev in events[:30]:  # Show latest 30 events
                self.log_list.insert(tk.END, ev)

        except Exception as e:
            print(f"UI update loop error: {e}")

        # Loop roughly at ~20 FPS (50ms interval)
        self.root.after(50, self._update_loop)

def main():
    root = tk.Tk()
    app = DesktopMonitorApp(root)
    root.mainloop()

if __name__ == "__main__":
    main()
