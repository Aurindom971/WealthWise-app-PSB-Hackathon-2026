from dataclasses import dataclass

@dataclass
class ConditionerConfig:
    # Algorithm to use: "SHA3_512" or "BLAKE3"
    algorithm: str = "SHA3_512"
    
    # Enable debugging mode (logs entropy values to terminal only - never write to disk)
    debug_mode: bool = False
