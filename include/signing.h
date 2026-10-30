#ifndef SIGNING_H
#define SIGNING_H

#include <stdint.h>
#include <stddef.h>

// Signature verification using stored RSA key
int verify_signature_file(const char *key_path, 
                          const uint8_t *data, 
                          size_t data_len,
                          const uint8_t *expected_sig,
                          size_t sig_len);

// Load and parse PEM key
int load_rsa_key(const char *pem_path, uint8_t **private_key);
int load_signature(const char *sig_path, uint8_t **sig_data);

// Signature generation for HID reports
uint8_t *compute_signature(const uint8_t *data,
                           size_t data_len,
                           size_t *sig_len);

// Serial number handling
void write_serial(size_t buf_size, uint64_t serial);
uint64_t read_serial(void);

#endif // SIGNING_H