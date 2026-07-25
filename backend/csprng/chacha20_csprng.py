import threading
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from .seed_manager import SeedManager

class ChaCha20Csprng:
    """
    ChaCha20-based Cryptographically Secure Random Number Generator.
    Splits the 512-bit seed into a 256-bit key and 128-bit initial nonce/counter parameter.
    """
    def __init__(self, seed_manager: SeedManager):
        self.seed_manager = seed_manager
        self.lock = threading.Lock()
        
        # Keystream generator parameters
        self._key: bytes = b""
        self._nonce: bytes = b""
        self._counter: int = 0
        self._cipher = None
        self._encryptor = None
        
        self.reseed()

    def reseed(self) -> None:
        """
        Splits the current 64-byte seed:
        - First 32 bytes (256 bits) as the ChaCha20 key.
        - Next 16 bytes (128 bits) as the base nonce.
        - The remaining 16 bytes can initialize a counter or serve as verification bits.
        """
        with self.lock:
            seed = self.seed_manager.get_seed()
            self._key = seed[:32]
            # ChaCha20 uses a 16-byte nonce in standard configurations
            self._nonce = seed[32:48]
            self._counter = 0
            
            # Re-initialize the cipher
            # We use an empty byte payload and encrypt it to extract the key stream.
            self._cipher = Cipher(algorithms.ChaCha20(self._key, self._nonce), mode=None)
            self._encryptor = self._cipher.encryptor()

    def generate_bytes(self, length: int) -> bytes:
        """
        Generates security-hardened random bytes by running the keystream.
        """
        if length <= 0:
            raise ValueError("Requested byte length must be positive")

        with self.lock:
            # We encrypt a block of zero bytes to fetch keystream blocks.
            # This generates identical cryptographically secure keystream bytes
            # matching the ChaCha20 implementation.
            zeros = bytes(length)
            random_bytes = self._encryptor.update(zeros)
            return random_bytes
