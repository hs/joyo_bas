# JoyoBas

A bank account statement crawler for Joyo-Bank AccessJ.

## Installation

JoyoBas requires google chrome and chromedriver.

To install chromedriver with HomeBrew(MacOS):

    $ brew tap homebrew/cask
    $ brew cask install chromedriver

Then

    $ bundle install --path vendor/bundle

Copy config.yml.sample to config.yml and edit it.

* Be sure to set the 'headless' option to 'true' when running from cron.

## Usage

From command line:

    $ bundle exec exe/joyo_bas get

Note: Running joyo_bas more than once in the same month results in duplicate entries for the previous month.

From cron:

Run on the 1st of each month at 10 o'clock.

    $ crontab -e
    0 10 1 * * /bin/bash -l -c 'cd /[INSTALL_PATH]/joyo_bas/ && /usr/bin/bundle exec exe/joyo_bas get'

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hs/joyo_bas.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

----
# JoyoBas

常陽銀行のAccessJから前月分の明細をダウンロードします。

## インストール

JoyoBasを動かすにはGoogle chromeとchromedriverをあらかじめインストールしておく必要があります。

chromedriverは、MacOSならHomebrewなどを使ってインストールしてください。

    $ brew tap homebrew/cask
    $ brew cask install chromedriver

準備が整ったら必要なgemをインストールします。

    $ bundle install --path vendor/bundle

最後に、config.yml.sample を config.yml にコピーして編集します。

* もしcronから実行する場合は、'headless'オプションを'true'にします。

## 使いかた

コマンドラインから:

    $ bundle exec exe/joyo_bas get

注意: 同じ月に複数回 joyo_basを実行すると、前月の明細が重複して登録されてしまいます。

crontab に登録:

毎月1日の10時に実行する場合、例えば以下のように設定します。

    $ crontab -e
    0 10 1 * * /bin/bash -l -c 'cd /[インストール先]/joyo_bas/ && /usr/bin/bundle exec exe/joyo_bas get'

## 貢献

Bug reports and pull requests are welcome on GitHub at https://github.com/hs/joyo_bas.

## ライセンス

[MIT License](https://opensource.org/licenses/MIT).です。

