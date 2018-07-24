require 'net/http'

module Ecpay
  module Invoice
    class CreateService
      def initialize(params = {})
        @params = params
      end

      def run
        create(@params)
      end

      private

      def url
        'https://einvoice-stage.ecpay.com.tw/Invoice/Issue'
      end

      def sample_params
        # 基本參數
        {
          'TimeStamp' => Time.current.to_i.to_s,
          'MerchantID' => '2000132',
          'RelateNumber' => SecureRandom.hex(10), # 訂單編號
          'CustomerEmail' => 'service@5xruby.tw', # 客戶信箱
          'TaxType' => '1', # 課稅類別
          'InvType' => '07', # 字軌類別

        # 商品參數
          'SalesAmount' => 1900, #總金額
          'ItemCount' => '3|2', #商品數量
          'ItemPrice' => '300|500', #商品單價
          'ItemAmount' => '900|1000', #商品小計
          'ItemName' => '衣服|褲子', #商品名稱
          'ItemWord' => '件|件', #商品單位

        # 發票參數
          'Print' => '0', # 要列印嗎？ 0代表不要 1代表要
          'Donation' => '1', # 要捐嗎？ 0代表不要 1代表要
          'LoveCode' => '168001', # 要捐給誰，一個7字元的愛心碼
        }
      end

      def create(params)
        params['CheckMacValue'] = compute_check_mac_value(params)
        uri = URI(url)
        response = Net::HTTP.post_form(uri, params)
        body = response.body.force_encoding('UTF-8')
        CGI.parse(body).transform_values(&:first)
      end

      def compute_check_mac_value(params)
        # 先將參數備份
        params = params.dup

        # 某些參數需要先進行 url encode
        %w[CustomerName CustomerAddr CustomerEmail].each do |key|
          next if params[key].nil?
          params[key] = urlencode_dot_net(params[key])
        end

        # 某些參數不需要參與 CheckMacValue 的計算
        exclude_keys = %w[InvoiceRemark ItemName ItemWord ItemRemark]
        params = params.reject do |k, _v|
          exclude_keys.include? k
        end

        # 轉成 query_string
        query_string = to_query_string(params)
        # 加上 HashKey 和 HashIV
        query_string = "HashKey=ejCk326UnaZWKisg&#{query_string}&HashIV=q9jcZX8Ib9LM8wYk"
        # 進行 url encode
        raw = urlencode_dot_net(query_string)
        # 套用 MD5 後轉大寫
        Digest::MD5.hexdigest(raw).upcase
      end

      def urlencode_dot_net(raw_data)
        # url encode 後轉小寫
        encoded_data = CGI.escape(raw_data).downcase
        # 調整成跟 ASP.NET 一樣的結果
        encoded_data.gsub!('%21', '!')
        encoded_data.gsub!('%2a', '*')
        encoded_data.gsub!('%28', '(')
        encoded_data.gsub!('%29', ')')
        encoded_data
      end

      def to_query_string(params)
        # 對小寫的 key 排序
        params = params.sort_by do |key, _val|
          key.downcase
        end

        # 組成 query_string
        params = params.map do |key, val|
          "#{key}=#{val}"
        end
        params.join('&')
      end

    end
  end
end
