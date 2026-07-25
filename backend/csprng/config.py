from dataclasses import dataclass

@dataclass
class CSPRNGConfig:
    # Reseed interval in seconds (Phase 7 requirements specify default 60 seconds)
    # We set default to 60.0. For dashboard demos, we can allow lower values or track time elapsed.
    reseed_interval: float = 60.0
    
    # Default output lengths
    default_byte_length: int = 32
    default_nonce_length: int = 16
    
    # Enable dashboard HUD outputs
    dashboard_enabled: bool = True
    
    # Algorithm details
    algorithm_name: str = "ChaCha20"
