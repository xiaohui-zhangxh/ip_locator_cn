require 'ip_locator_cn/qqwry/provinces'
require 'ip_locator_cn/qqwry/city_directly'
require 'ip_locator_cn/qqwry/isp'

module IpLocatorCn
  class QQWry
    IP_ENTRY_BYTES = 7

    attr_reader :first_ip_pos, :last_ip_pos, :total_ips, :debug

    def initialize(dat_path: nil, live_dat: false, debug: false)
      @debug = debug
      if live_dat
        live_load_dat
        parse_dat_info
      elsif dat_path
        @io = File.open(dat_path, 'rb')
        parse_dat_info
      end
    end

    # return: <Hash> result
    # result['ip']              输入的ip
    # result['country']         国家 如 中国
    # result['province']        省份信息 如 河北省
    # result['city']            市区 如 邢台市
    # result['county']          郡县 如 威县
    # result['isp']             运营商 如 联通
    # result['area']            最完整的信息 如 中国河北省邢台市威县新科网吧(北外街)
    # result['origin_country']  解析之前的原始信息
    # result['origin_area']     解析之前的原始信息
    def resolve(ip)
      location = location_from_ip(ip)
      extract_location(location[:country]).tap do |result|
        result[:ip] = ip
        result[:country] ||= ''
        result[:province] ||= ''
        result[:city] ||= ''
        result[:county] ||= ''
        result[:isp] = get_isp(location[:area]) || ''
        result[:area] = [
          result[:country],
          result[:province],
          result[:city],
          result[:county],
          location[:area]
        ].join
        result[:origin_country] = location[:country]
        result[:origin_area] = location[:area]
      end
    end

    def location_from_ip(ip)
      info = {}
      pos = locate_ip_pos(ip)
      log "pos is #{pos}"
      # 用户IP所在范围的开始地址
      seek(pos)
      begin_ip = long2ip(read_ip)
      log "begin_ip is #{begin_ip}"
      # 用户IP所在范围的结束地址
      offset = getlong3
      seek(offset)
      endip = long2ip(read_ip)
      log "endip is #{endip}"
      log "offset is #{offset}"
      byte = read(1) # 标志字节
      case byte.ord
      when 1
        # 标志字节为1，表示国家和区域信息都被同时重定向
        country_offset = getlong3 # 重定向地址
        seek(country_offset)
        byte = read(1) # 标志字节
        case byte.ord
        when 2
          seek(getlong3)
          info[:country] = getstring
          seek(country_offset + 4)
          info[:area] = getarea
        else
          info[:country] = getstring(byte)
          info[:area] = getarea
        end
      when 2
        # 标志字节为2，表示国家信息被重定向
        seek(getlong3)
        info[:country] = getstring
        seek(offset + 8)
        info[:area] = getarea
      else
        info[:country] = getstring(byte)
        info[:area] = getarea
      end

      info[:country] = encoding_convert(info[:country])
      info[:area] = encoding_convert(info[:area])

      log "country is #{info[:country]}"
      log "area is #{info[:area]}"

      if info[:country] == ' CZ88.NET' || info[:country] == '纯真网络'
        info[:country] = 'Unknown'
      end

      info[:area] = '' if info[:area] == ' CZ88.NET'

      info
    end

    # 提取 四川省成都市高新区 => 中国 四川 成都市 高新区
    def extract_location(str)
      collection = {}
      seperator_sheng = '省'
      seperator_shi = '市'
      seperator_xian = '县'
      seperator_qu = '区'
      is_city_directly = false

      # 省份
      if str.include?(seperator_sheng)
        collection[:province], str = str.split(seperator_sheng, 2)
      else
        province = (PROVINCES + CITY_DIRECTLY).find { |x| str.start_with?(x) }
        if province
          collection[:province] = province
          is_city_directly = CITY_DIRECTLY.include?(province)
          str = str[province.length..-1]
          str = str[1..-1] if str.start_with?(seperator_shi) # 上海市浦东区 => [上海, 市浦东区] => [上海, 浦东区]
        end
      end

      return { country: str } unless collection.key?(:province)

      # 市
      if str.include?(seperator_shi)
        collection[:city], str = str.split(seperator_shi, 2)
        collection[:city] += seperator_shi
      end

      # 县
      if str.include?(seperator_xian)
        collection[:county], str = str.split(seperator_xian, 2)
        collection[:county] += seperator_xian
      end

      # 区
      if !collection.key?(:county) && str.include?(seperator_qu)
        collection[:county], str = str.split(seperator_qu, 2)
        collection[:county] += seperator_qu
        if is_city_directly
          collection[:city] = collection[:county]
          collection.delete(:county)
        end
      end

      collection[:country] = '中国'
      collection
    end

    private

    def download(url)
      log "downloading #{url}"
      open(url)
    end

    def live_load_dat
      require 'open-uri'
      (copywrite = download(IpLocatorCn.copywrite_url).read) && nil
      (qqwry = download(IpLocatorCn.live_data_url).read.bytes) && nil
      key = copywrite.unpack('V6')[5]
      log "qqwry decoding key is #{key}"
      (0...0x200).each do |i|
        key *= 0x805
        key += 1
        key &= 0xFF
        qqwry[i] ^= key
      end
      (qqwry = Zlib::Inflate.inflate(qqwry.pack('C*'))) && nil
      @io = StringIO.new(qqwry)
    end

    def parse_dat_info
      @first_ip_pos = getlong4
      @last_ip_pos = getlong4
      @total_ips = (last_ip_pos - first_ip_pos) / IP_ENTRY_BYTES
      log "total ip ranges: #{total_ips}"
    end

    def get_isp(str)
      ISP.find { |x| str.include?(x) }
    end

    # b-tree search ip from qqwry.dat
    def locate_ip_pos(ip)
      x = ip2long(ip)
      min = 0
      max = total_ips

      while min <= max
        # b-tree search
        i = ((min + max) / 2).floor
        pos = first_ip_pos + i * IP_ENTRY_BYTES
        seek(pos)
        # get middle ip
        y = read_ip
        if x < y
          # user ip < middle ip
          max = i - 1
        else
          # user ip > middle ip, read next ip entry
          read(3)
          y = read_ip
          if x > y
            # user ip > next ip
            min = i + 1
          else
            return pos
          end
        end
      end
      -1
    end

    def seek(n)
      @io.seek(n)
    end

    def read(n)
      @io.read(n)
    end

    def read_ip
      ipparts2long(read(4).reverse.bytes)
    end

    def getlong4
      read(4).unpack('V')[0]
    end

    def getlong3
      (read(3) + "\0").unpack('V')[0]
    end

    def ip2long(ip)
      parts = ip.split('.').map(&:to_i)
      ipparts2long(parts)
    end

    def ipparts2long(parts)
      0.upto(3).map { |i| parts[i] << ((3 - i) * 8) }.sum
    end

    def long2ip(n)
      0.upto(3).map { |i| (n >> ((3 - i) * 8)) & 0xFF }.join('.')
    end

    def getstring(data = '')
      char = read(1)
      while char.ord > 0
        data += char
        char = read(1)
      end

      data
    end

    def getarea
      char = read(1)
      case char.ord
      when 0
        return ''
      when 1, 2
        seek(getlong3)
        return getstring
      else
        return getstring(char)
      end
    end

    def encoding_convert(str)
      ec = Encoding::Converter.new('GBK', 'UTF-8')
      result = ec.convert(str)
      ec.finish
      result
    end

    def log(msg)
      puts "[#{Time.now}] => #{msg}" if debug
    end
  end
end
