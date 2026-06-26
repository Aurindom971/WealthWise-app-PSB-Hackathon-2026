const { ensureCollection } = require("./src/config/qdrant");

(async () => {
  await ensureCollection();
  console.log("Qdrant connection successful");
})();


require('dotenv').config();

console.log(process.env.QDRANT_URL);
console.log(process.env.QDRANT_API_KEY?.substring(0, 10));