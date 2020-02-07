# JoyoBas

A bank account statement crawler for Joyo-Bank AccessJ.

## Installation

JoyoBas requires google chrome and chromedriver.

To install chromedriver with HomeBrew:

    $ brew tap homebrew/cask
    $ brew cask install chromedriver

Then

    $ bundle install --path vendor/bundle

Copy config.yml.sample to config.yml and edit it.

## Usage

    $ bundle exec exe/joyo_bas get

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hs/joyo_bas.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

----
# JoyoBas

常陽銀行のAccessJから前月分の明細をダウンロードします。

## インストール

JoyoBasを動かすにはGoogle chromeとchromedriverをあらかじめインストールしておく必要があります。

chromedriverは、Homebrewなどを使ってインストールしてください。

    $ brew tap homebrew/cask
    $ brew cask install chromedriver

準備が整ったら必要なgemをインストールします。

    $ bundle install --path vendor/bundle

最後に、config.yml.sample を config.yml にコピーして編集します。

## 使いかた

    $ bundle exec exe/joyo_bas get

## 貢献

Bug reports and pull requests are welcome on GitHub at https://github.com/hs/joyo_bas.

## ライセンス

[MIT License](https://opensource.org/licenses/MIT).です。

