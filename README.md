# 綠界電子發票串接範例

code 抓下來後在 bash 下輸入：

```bash
bundle
rails c
```

進入 rails console 後輸入：

```
params = Ecpay::Invoice::CreateService.new.send(:sample_params)
relate_number = params["RelateNumber"]
Ecpay::Invoice::CreateService.new(params).run
Ecpay::Invoice::FindService.new(relate_number).run
```

即可執行範例程式碼