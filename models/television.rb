require_relative( '../db/sql_runner.rb')
require_relative( './manufacturer.rb')

class Television

  # Make attributes readable
  attr_reader :id, :model_no, :manufacturer_id, :cost_price, :retail_price, :stock

  # Make sure variables are set upon new instances
  def initialize( details )
    @id = details[ 'id' ].to_i unless details[ 'id' ].nil?
    @model_no = details[ 'model_no' ]
    @manufacturer_id = details[ 'manufacturer_id' ].to_i
    @stock = details[ 'stock' ].to_i
    @cost_price = details[ 'cost_price' ].to_f
    @retail_price = details[ 'retail_price' ].to_f unless details[ 'retail_price' ].nil?
  end

  # sace instance to database and set id based on sql given id
  def save()
    sql = "
    INSERT INTO televisions
    ( model_no, manufacturer_id, stock, cost_price )
    VALUES
    ( '#{@model_no}', #{@manufacturer_id}, #{@stock}, #{@cost_price} )
    RETURNING *;
    "
    @id = SqlRunner.run( sql )[0][ 'id' ].to_i
    update_model()
    calc_retail_price()
    update()
  end

  # convert pg result of many rows to array of instances
  def self.get_many( sql )
    results = SqlRunner.run( sql )
    return results.map { |television| Television.new( television ) }
  end

  # search rows by id and delete result if found
  def self.delete( id )
    sql = "DELETE FROM televisions where id = #{id}"
    SqlRunner.run( sql )
  end

  # search rows by id and return result if found
  def self.find( id )
    sql = "SELECT * FROM televisions WHERE id = #{id};"
    television = SqlRunner.run( sql )[0]
    return Television.new( television )
  end

  # return all televisions
  def self.all()
    sql = "SELECT * FROM televisions;"
    return Television.get_many( sql )
  end

  # return manufacturer of given television
  def manufacturer()
    sql = "SELECT * FROM manufacturers WHERE id = #{manufacturer_id}"
    manufacturer = SqlRunner.run( sql )[0]
    return Manufacturer.new( manufacturer )
  end

  # update all columns of given televisions row
  def update()
    sql = "
    UPDATE televisions SET 
    ( model_no, manufacturer_id, stock, cost_price, retail_price )
    =
    ( '#{@model_no}', #{@manufacturer_id}, #{@stock}, #{@cost_price}, #{@retail_price} )
    WHERE id = #{id};
    "
    SqlRunner.run( sql )
  end

  # update only the stock column of given televisions row
  def update_stock( new_stock )
    @stock += new_stock
    update()
  end

  # add manufacturers model prefix to television model no
  def update_model()
    sql = "SELECT model_temp FROM manufacturers WHERE id = #{@manufacturer_id};"
    @model_no = SqlRunner.run( sql )[0][ 'model_temp' ].to_s + "-" + @model_no
  end

  # calculate retail price of television based on the manufacturers markup and the telvisions cost price
  def calc_retail_price()
    sql = "SELECT markup FROM manufacturers WHERE id = #{@manufacturer_id};"
    markup = SqlRunner.run( sql )[0][ 'markup' ].to_f
    @retail_price = @cost_price * markup
    @retail_price = @retail_price.round(-2)
  end

  # decrease the stock of a television by a given amount
  def sell( number )
    @stock -= number
  end

end
