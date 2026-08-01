const { saveKycToDb, getKycFromDb, deleteKycFromDb } = require('../db');

/**
 * Save or update KYC details in PostgreSQL
 */
async function saveKyc(req, res) {
  try {
    const { cus_id, kyc_data } = req.body;
    const identifier = cus_id || (kyc_data ? kyc_data.cus_id : null) || 'CUST1';

    if (!identifier) {
      return res.status(400).json({
        success: false,
        message: 'Customer ID is required'
      });
    }

    const savedRecord = await saveKycToDb(identifier, kyc_data || req.body);

    console.log(`[KYC] Record saved successfully for Customer ID: ${identifier}`);

    return res.status(200).json({
      success: true,
      message: 'KYC details verified and saved to database',
      kyc_record: savedRecord
    });
  } catch (error) {
    console.error('[KYCController] Error saving KYC:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Failed to save KYC record to database.'
    });
  }
}

/**
 * Get KYC status and details by Customer ID
 */
async function getKycStatus(req, res) {
  try {
    const cusId = req.params.cus_id || 'CUST1';
    const kycRecord = await getKycFromDb(cusId);

    if (!kycRecord) {
      return res.status(200).json({
        success: true,
        status: 'PENDING',
        message: 'No KYC record found. Verification required.'
      });
    }

    return res.status(200).json({
      success: true,
      kyc_record: kycRecord
    });
  } catch (error) {
    console.error('[KYCController] Error fetching KYC status:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve KYC status.'
    });
  }
}

/**
 * Delete / Remove KYC record by Customer ID
 */
async function deleteKyc(req, res) {
  try {
    const cusId = req.params.cus_id || req.body.cus_id || 'CUST1';
    const deletedRecord = await deleteKycFromDb(cusId);

    console.log(`[KYC] Record marked as REMOVED for Customer ID: ${cusId}`);

    return res.status(200).json({
      success: true,
      message: `KYC profile ${cusId} marked as REMOVED in DB`,
      kyc_record: deletedRecord
    });
  } catch (error) {
    console.error('[KYCController] Error deleting KYC record:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Failed to remove KYC record from database.'
    });
  }
}

module.exports = {
  saveKyc,
  getKycStatus,
  deleteKyc
};
