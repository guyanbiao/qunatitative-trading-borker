class Exchange::Entry
  def self.find(id)
    exchanges[id]
  end

  def self.exchanges
    {
      'huobi' => Exchange::Huobi,
      'bitget' => Exchange::Bitget
    }
  end
end