const { ensureCollection } = require("./src/config/qdrant");

(async () => {
  try {
    await ensureCollection();
    console.log("Qdrant connection successful");
  } catch (error) {
    console.error("Qdrant connection failed:", error.message || error);
  }
})();
