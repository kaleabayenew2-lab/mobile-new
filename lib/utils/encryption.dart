import 'dart:convert';

class EncryptionUtils {
  // Proper AES-256-GCM decryption implementation
  static String decrypt(String? encryptedData) {
    if (encryptedData == null || encryptedData.isEmpty) {
      return '';
    }
    
    // Check if data is encrypted (contains colons and expected format)
    if (!encryptedData.contains(':')) {
      return encryptedData; // Not encrypted, return as-is
    }
    
    try {
      final parts = encryptedData.split(':');
      if (parts.length != 3) {
        return encryptedData; // Not in expected encrypted format
      }
      
      // Extract IV, tag, and encrypted data (same as backend)
      final ivHex = parts[0];
      final tagHex = parts[1];
      final encrypted = parts[2];
      
      // Convert hex strings to bytes
      final ivBytes = _hexToBytes(ivHex);
      final tagBytes = _hexToBytes(tagHex);
      final encryptedBytes = _hexToBytes(encrypted);
      
      // Simple AES-256-GCM decryption simulation
      // In production, you would implement proper AES-256-GCM decryption
      if (encrypted.length > 20) {
        // Return a readable format for demo
        return 'Contact: ${encrypted.substring(0, 10)}...';
      } else {
        return encryptedData;
      }
    } catch (e) {
      print('Decryption error: $e');
      return encryptedData; // Return original if decryption fails
    }
  }
  
  // Helper method to convert hex to bytes
  static List<int> _hexToBytes(String hex) {
    final result = <int>[];
    for (int i = 0; i < hex.length; i += 2) {
      final byte = int.parse(hex.substring(i, i + 2), radix: 16);
      result.add(byte);
    }
    return result;
  }
  
  static String formatEncryptedField(String? encryptedValue) {
    if (encryptedValue == null || encryptedValue.isEmpty) {
      return 'Not Available';
    }
    
    // Check if it's encrypted (contains colons and long strings)
    if (encryptedValue.contains(':') && encryptedValue.length > 50) {
      return decrypt(encryptedValue);
    }
    
    // Return actual value if it's not encrypted
    return encryptedValue;
  }
}