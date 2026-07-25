import sys
import os
import time
import json
import logging

# Ensure parent directory is in sys.path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from aquarium_pipeline import PipelineConfig, VideoPlayer
from cv_engine.config import CVEngineConfig
from cv_engine.feature_extractor import FeatureExtractor

from entropy_engine.config import EntropyConfig
from entropy_engine.feature_normalizer import FeatureNormalizer
from entropy_engine.entropy_collector import EntropyCollector
from entropy_engine.entropy_metrics import EntropyMetricsCalculator
from entropy_engine.entropy_pool import EntropyPool

from entropy_mixer.config import MixerConfig
from entropy_mixer.entropy_mixer import EntropyMixer

from crypto_conditioner.config import ConditionerConfig
from crypto_conditioner.entropy_conditioner import EntropyConditioner
from crypto_conditioner.sha3_conditioner import Sha3Conditioner
from crypto_conditioner.blake3_conditioner import Blake3Conditioner

from csprng.config import CSPRNGConfig
from csprng.seed_manager import SeedManager
from csprng.chacha20_csprng import ChaCha20Csprng
from csprng.random_generator import RandomByteGenerator
from csprng.reseed_manager import ReseedManager
from csprng.health_monitor import CsprngHealthMonitor

# Configure logger
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("AquariumCSPRNGMain")

def print_csprng_dashboard(stats: dict, cfg: CSPRNGConfig, random_samples: dict):
    """Renders a live terminal view of the CSPRNG generator HUD."""
    next_reseed = max(0.0, cfg.reseed_interval - stats["seed_age_seconds"])
    
    print("=" * 65)
    print("         ChaCha20 SECURE RANDOM GENERATOR (CSPRNG) - LIVE HUD")
    print("=" * 65)
    print(f"  Generator Status:    {stats['generator_status']}")
    print(f"  Generator Health:    {stats['generator_health']}")
    print(f"  Current Algorithm:   {cfg.algorithm_name}")
    print("-" * 65)
    print(f"  Last Reseed Time:    {time.ctime(stats['last_reseed_time'])}")
    print(f"  Reseed Count:        {stats['reseed_count']}")
    print(f"  Next Reseed In:      {next_reseed:.1f} seconds")
    print(f"  Bytes Generated:     {stats['bytes_generated']} Bytes")
    print(f"  Generation Rate:     {stats['generation_rate_bps']:.2f} B/s")
    print("-" * 65)
    print("  LIVE CRYPTOGRAPHIC SAMPLES (strictly from keystream):")
    print(f"    - Hex (32 Bytes):   {random_samples['hex']}")
    print(f"    - Base64 (16 B):    {random_samples['base64']}")
    print(f"    - Uint32 Integer:   {random_samples['uint32']}")
    print(f"    - Uint64 Integer:   {random_samples['uint64']}")
    print(f"    - Secure Nonce:     {random_samples['nonce']}")
    print("=" * 65)

def main():
    logger.info("Initializing Video + CV + Pool + Mixer + Conditioner + CSPRNG Pipeline...")

    # Load configurations
    pipeline_cfg = PipelineConfig()
    cv_cfg = CVEngineConfig()
    cv_cfg.enable_visualization = False
    
    entropy_cfg = EntropyConfig()
    mixer_cfg = MixerConfig()
    cond_cfg = ConditionerConfig()
    
    csprng_cfg = CSPRNGConfig()
    # Let's set a fast reseed for demo purposes (e.g. 10s) so it triggers quickly
    csprng_cfg.reseed_interval = 10.0

    # Ingestion & CV modules
    player = VideoPlayer(pipeline_cfg)
    extractor = FeatureExtractor(cv_cfg)

    # Entropy & Mixing modules
    normalizer = FeatureNormalizer(entropy_cfg)
    collector = EntropyCollector(entropy_cfg)
    metrics_calc = EntropyMetricsCalculator(entropy_cfg)
    pool = EntropyPool(entropy_cfg)
    mixer = EntropyMixer(mixer_cfg, pool)

    # Cryptographic Conditioner modules
    conditioner = EntropyConditioner()
    if cond_cfg.algorithm == "BLAKE3":
        hash_engine = Blake3Conditioner()
    else:
        hash_engine = Sha3Conditioner()

    # Define a helper callback to get a fresh conditioned digest
    def fetch_fresh_seed_callback() -> str:
        # 1. Gather mixed sources
        combined = mixer.collect_all_entropy()
        # 2. Serialize
        serialized = conditioner.serialize(combined)
        # 3. Condition / Hash
        conditioned = hash_engine.condition(serialized)
        return conditioned["digest"]

    # Initialize CSPRNG Seed Manager
    seed_manager = SeedManager()
    
    # Start video player thread to start generating pool entropy
    player.start()
    
    logger.info("Gathering initial entropy to seed CSPRNG...")
    # Gather first seed package
    initial_seed_hex = None
    while initial_seed_hex is None:
        frame_package = player.get_next_frame(timeout=1.0)
        if frame_package is not None:
            frame, metadata = frame_package
            feature_vector, _ = extractor.process_frame(frame, metadata)
            norm_features = normalizer.normalize(feature_vector)
            entropy_scores = metrics_calc.calculate_contributions(norm_features)
            pool.accumulate(entropy_scores)
            initial_seed_hex = fetch_fresh_seed_callback()
        time.sleep(0.05)

    # Load seed securely in memory
    seed_manager.load_seed(initial_seed_hex)

    # Initialize CSPRNG and formatted generator
    csprng = ChaCha20Csprng(seed_manager)
    generator = RandomByteGenerator(csprng)

    # Initialize Reseed Manager linking the callback
    reseed_mgr = ReseedManager(csprng_cfg, seed_manager, csprng, fetch_fresh_seed_callback)
    monitor = CsprngHealthMonitor(csprng_cfg, seed_manager, generator, reseed_mgr)

    try:
        while True:
            # 1. Read and process next frame to feed pool
            frame_package = player.get_next_frame(timeout=1.0)
            if frame_package is not None:
                frame, metadata = frame_package
                feature_vector, _ = extractor.process_frame(frame, metadata)
                norm_features = normalizer.normalize(feature_vector)
                entropy_scores = metrics_calc.calculate_contributions(norm_features)
                pool.accumulate(entropy_scores)

            # 2. Manage automatic reseeding check
            _ = reseed_mgr.check_and_reseed()

            # 3. Generate sample randomness for live display
            samples = {
                "hex": generator.generate_hex(16),
                "base64": generator.generate_base64(12),
                "uint32": generator.generate_uint32(),
                "uint64": generator.generate_uint64(),
                "nonce": generator.generate_nonce(8)
            }

            # 4. Render live dashboard
            stats = monitor.get_stats()
            print_csprng_dashboard(stats, csprng_cfg, samples)

            time.sleep(0.1)

    except KeyboardInterrupt:
        logger.info("Pipeline stopped by user.")
    finally:
        logger.info("Shutting down resources...")
        player.close()
        logger.info("Pipeline shut down successfully.")

if __name__ == "__main__":
    main()
