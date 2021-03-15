# frozen_string_literal: true
module DataEncryptor
  CIPHER_ALGO = 'aes-256-cbc'
  DIGEST_ALGO = 'SHA1'
  KEY_LEN = 32 # key length for aes-256

  class Error < StandardError
  end

  module_function

  def encrypt(data)
    encryptor = ActiveSupport::MessageEncryptor.new(
      Rails.application.secrets.secret_key_base[0...KEY_LEN],
      cipher: CIPHER_ALGO,
      digest: DIGEST_ALGO
    )
    encryptor.encrypt_and_sign(data)
  end

  def decrypt(payload)
    encryptor = ActiveSupport::MessageEncryptor.new(
      Rails.application.secrets.secret_key_base[0...KEY_LEN],
      cipher: CIPHER_ALGO,
      digest: DIGEST_ALGO
    )
    encryptor.decrypt_and_verify(payload)
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveSupport::MessageEncryptor::InvalidMessage => e
    raise Error, e.message
  end
end
