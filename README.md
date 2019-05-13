英語PDFを翻訳するツール

## 使い方

### 基本の使い方

```
bundle install
```

```
bundle exec ruby pdfTrans.rb --input <ファイル名>
```

```
bundle exec ruby pdfTrans.rb --url <URL> --output <Filename>
```

- ```--input```オプションで入力するファイルを指定
- ```--url```オプションでインターネット上のファイルも入力可能
- ```<ファイル名_translated.txt>```というファイルが出力される。一文ごとに翻訳され、英→日 英→日…という順になっている。


### その他オプション
- --output
  - 出力ファイル名を指定
- --jp
  - 日本語のみ出力
- --en
  - 英語のみ出力 
- --head
  - ヘッドレスにしない
