
class Pay2goService

  def initialize(order, hash={})
    @order = order
    @timestamp = order.created_at.to_i
    @merchant_order_no = order.order_number
    @total_price = order.total
    @hash_key = ENV['hash_key']
    @hash_iv = ENV['hash_iv']
    @merchant_id = ENV['merchant_id']
    @hash = hash
  end

  def aes_encrypt
    str = "MerchantID=#{@merchant_id}&TimeStamp=#{@timestamp}&Version=1.0&MerchantOrderNo=#{@merchant_order_no}&Amt=#{@total_price}&ItemDesc=sample"
    cipher = OpenSSL::Cipher::AES.new(256, :CBC)

    cipher.encrypt
    cipher.key = ENV['hash_key']
    cipher.iv  = ENV['hash_iv']
    encrypted = cipher.update(str) << cipher.final
    encoded = encrypted.unpack('H*')[0]
  end

  class << self
    def aes_decrypt(data)
      aes = OpenSSL::Cipher::Cipher.new("AES-256-CBC")
      aes.decrypt
      aes.key = ENV['hash_key']
      aes.iv  = ENV['hash_iv']
      aes.padding = 0

      decrypted_data = aes.update([data].pack('H*')) << aes.final
      decrypted_data.force_encoding('UTF-8')

      self.strippadding(decrypted_data)

    end

    def strippadding(decrypted_data)
        padding_num = decrypted_data[-1].ord
        padding_chr = decrypted_data[-1]
      if /#{padding_chr}{#{padding_num}}/i.match(decrypted_data)
        decrypted_data_length = decrypted_data.size - padding_num -1
        decrypted_data[0..decrypted_data_length]
      else
        decrypted_data  
      end      
    end

  end



  def sha256_encrypt
    str = self.aes_encrypt
    encrypted = "HashKey=#{ENV['hash_key']}&#{str}&HashIV=#{ENV['hash_iv']}"
    Digest::SHA256.hexdigest(encrypted).upcase
  end



  def check(code)
    @code = self.send(code)
    d = Digest::SHA256.hexdigest(@code).upcase
  end

  def check_code
    "HashIV=#{@hash_iv}&Amt=#{@total_price}&MerchantID=#{@merchant_id}&MerchantOrderNo=#{@merchant_order_no}&TradeNo=#{@hash[:TradeNo]}&HashKey=#{@hash_key}"
  end

  def check_value
    "HashKey=#{@hash_key}&Amt=#{@total_price}&MerchantID=#{@merchant_id}&MerchantOrderNo=#{@merchant_order_no}&TimeStamp=#{@timestamp}&Version=1.2&HashIV=#{@hash_iv}"
  end

  def state_query
    "IV=#{Pay2go.hash_iv}&Amt=#{@total_price}&MerchantID=#{Pay2go.merchant_id}&MerchantOrderNo=#{@merchant_order_no}&Key=#{Pay2go.hash_key}"
  end

end
