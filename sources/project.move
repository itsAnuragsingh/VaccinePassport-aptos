module VaccineModule::VaccinePassport {
    use std::string::{String};
    use aptos_framework::account;
    use aptos_framework::signer;
    use aptos_std::table::{Self, Table};

    /// Struct representing a vaccine passport record
    struct VaccineRecord has key {
        // Table mapping vaccine type to vaccination status
        vaccines: Table<String, bool>,
        // Optional verification from health authority
        verified: bool,
    }

    /// Error codes
    const E_NOT_AUTHORIZED: u64 = 1;
    const E_RECORD_EXISTS: u64 = 2;
    const E_RECORD_NOT_FOUND: u64 = 3;

    /// Create a new empty vaccine passport for a user
    public entry fun create_passport(account: &signer) {
        let user_addr = signer::address_of(account);
        
        // Check if record already exists
        assert!(!exists<VaccineRecord>(user_addr), E_RECORD_EXISTS);
        
        // Create new record with empty vaccine table
        let record = VaccineRecord {
            vaccines: table::new(),
            verified: false,
        };
        
        // Move the record to the user's account
        move_to(account, record);
    }

    /// Add or update vaccination status
    /// Only the user themselves or authorized health provider can update
    public entry fun add_vaccination(
        authority: &signer,
        user_addr: address,
        vaccine_type: String,
        status: bool
    ) acquires VaccineRecord {
        // Ensure record exists
        assert!(exists<VaccineRecord>(user_addr), E_RECORD_NOT_FOUND);
        
        // Get the vaccine record
        let record = borrow_global_mut<VaccineRecord>(user_addr);
        
        // Add or update the vaccination status
        if (table::contains(&record.vaccines, vaccine_type)) {
            *table::borrow_mut(&mut record.vaccines, vaccine_type) = status;
        } else {
            table::add(&mut record.vaccines, vaccine_type, status);
        }
    }
}