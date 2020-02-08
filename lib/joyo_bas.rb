require "joyo_bas/version"
require "joyo_bas/cli"
require 'selenium-webdriver'
require 'yaml'
require 'rubyxl'

module JoyoBas
  class Error < StandardError; end
  # Your code goes here...
  class Config
    attr_accessor :id, :password, :accounts, :path, :headless
    def initialize
      root = Gem::Specification.find_by_name("joyo_bas").gem_dir
      conf = YAML.load_file(File.join(root,'config.yml'))
      @headless = conf['headless']
      @id       = conf['id']
      @password = conf['password']
      @accounts = conf['accounts']
      save_to  = conf['save_to'] || File.join(root, 'data')
      file_name = conf['file_name'] || 'JoyoBAS.xlsx'
      @path = File.join(save_to, file_name)
    end
  end

  class Exporter
    def initialize(path, data)
      @path = path
      @data = data

      if File.exist?(@path)
        @wb = RubyXL::Parser.parse(@path)
      else
        @wb = RubyXL::Workbook.new
      end
    end

    def add_sheet(name)
      if wb = @wb['Sheet1']
        wb.sheet_name = name
        wb
      else
        @wb.add_worksheet(name)
      end
    end

    def append_data
      @data.each do |account, status|
        sheet = @wb[get_sheetname(account)] || add_sheet(get_sheetname(account))
        idx = get_last_line(sheet)
        if idx == 0
          get_header(account).each_with_index { |e,i|
            sheet.add_cell(0, i, e)
          }
          idx += 1
        end
        status.each_with_index { |line,l|
          line.each_with_index { |val,c|
            sheet.add_cell(idx + l, c, val)
          }
        }
      end
    end

    def save
      @wb.write(@path)
    end

    def get_last_line(sheet)
      l = 0
      (l += 1) until sheet[l].nil?
      l
    end

    def get_sheetname(account)
      if account.match(/^普通/)
        "#{Time.now.year}_#{account}"
      else
        account
      end
    end

    def get_header(account)
      if account.match(/^普通/)
        ['日付', '摘要', '', '出金', '入金', '残高']
      elsif account.match(/^定期/)
        ['預金番号', '預入日', '預金額', '期間', '満期日', '満期日取扱', '利率']
      else
        ['???']
      end
    end
  end

  class Crawler
    def initialize(conf)
      @conf = conf
      opts = Selenium::WebDriver::Chrome::Options.new
      opts.add_argument('--headless') if @conf.headless
      @wd = Selenium::WebDriver.for :chrome, options: opts
      # Resize window to avoid unclickable buttons
      @wd.manage.window.resize_to(1000,2000)
      @wait = Selenium::WebDriver::Wait.new(:timeout => 60)
      @sday = Date.new(Date.today.prev_month.year, Date.today.prev_month.month,1)
      @eday = Date.new(Date.today.prev_month.year, Date.today.prev_month.month,-1)
    end

    def fetch
      result = {}

      login
      @conf.accounts.each do |account|
        result[account] = []
        select_account(account)
        set_dates
        result[account] = get_statements
      end
      quit
      return result
    end

    private
    def get_login_url
      # トップページからログインパラメータ取得
      @wd.navigate.to 'https://www.joyobank.co.jp/access-j/index.html'
      @wd.find_element(:xpath, '//*[@id="access-j_securityset"]/div[@class="right"]/p/a[@class="rollover"]').attribute("href")
    end

    def login
      @wd.navigate.to get_login_url
      @wait.until{@wd.find_element(:xpath, '//button[@type="submit"]').displayed?}
      id = @wd.find_element(:xpath, '//input[@name="CLIENTIDNUMBER"]')
      pass = @wd.find_element(:xpath, '//input[@name="PASSWORD"]')
      id.send_keys(@conf.id)
      pass.send_keys(@conf.password)

      @wd.find_element(:xpath, '//input[@type="reset"]').location_once_scrolled_into_view
      @wd.find_element(:xpath, '//button[@type="submit"]').click
      @wait.until{@wd.find_element(:link, 'ヘルプデスク').displayed?}
    end

    def select_account(account)
      # [メインメニュー]->[入出金明細紹介]
      @wd.find_element(:link, '入出金明細照会').click

      # 口座選択
      #Selenium::WebDriver::Support::Select.new(@wd.find_element(:xpath, '//select[@name="KOUZA_JOUHOU"]')).select_by(:value, '1')
      Selenium::WebDriver::Support::Select.new(@wd.find_element(:xpath, '//select[@name="KOUZA_JOUHOU"]')).select_by(:text, account)
    end

    def set_date(prefix, date)
        yy = @wd.find_element(:xpath, "//select[@name='#{prefix}_YY']")
        Selenium::WebDriver::Support::Select.new(yy).select_by(:value, date.strftime('%Y'))
        mm = @wd.find_element(:xpath, "//select[@name='#{prefix}_MM']")
        Selenium::WebDriver::Support::Select.new(mm).select_by(:value, date.strftime('%0m'))
        dd = @wd.find_element(:xpath, "//select[@name='#{prefix}_DD']")
        Selenium::WebDriver::Support::Select.new(dd).select_by(:value, date.strftime('%0d'))
    end

    def set_dates
      # 「期間指定」を選択
      @wd.find_element(:xpath, '//input[@type="radio"][@name="RADIO_ACCT"][@value="2"]').click
      # 開始日
      set_date('TERM_DATE_START', @sday)
      # 終了日
      set_date('TERM_DATE_END', @eday)
    end

    def get_statements
      ret = []
      # [照会]ボタンをクリック
      @wd.find_element(:xpath, '//img[@alt="照会"]/..').click

      # 明細の取得
      begin
        @wd.find_elements(:xpath, '//div[@class="tableBlockYen03Outer"]//table//tr').each.with_index(1) do |_,i|
          tds = @wd.find_elements(:xpath, "//div[@class='tableBlockYen03Outer']//table//tr[#{i}]/td")
          next if tds.empty?
          ret << tds.map { |e| e.text }
        end
        # [次へ]ボタンがあれば繰り返す（未検証）　
        cont = (@wd.find_elements(:xpath, '//img[@alt="次へ"]').size > 0)
        if cont
          @wd.find_element(:xpath, '//img[@alt="次へ"]/..').click
          @wait.until{@wd.find_element(:xpath, '//img[@alt="戻る"]').displayed?}
        end
      end while cont
      ret
    end

    def quit
      # ログアウト
      @wd.find_element(:xpath, '//li[@id="headerLogout"]/a').click
      @wd.switch_to.alert.accept
      # 終了
      @wd.quit
    end
  end
end
