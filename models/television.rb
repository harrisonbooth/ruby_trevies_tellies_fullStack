require_relative( '../db/sql_runner.rb')
require_relative( './manufacturer.rb')

class Television
  attr_reader :id, :model_no, :stock, :manufacturer_id

  def initialize( details )
    @id = details[ 'id' ].to_i unless details[ 'id' ].nil?
    @model_no = details[ 'model_no' ]
    @manufacturer_id = details[ 'manufacturer_id' ].to_i
    @stock = details[ 'stock' ].to_i
  end

  def save()
    sql = "INSERT INTO televisions ( model_no, manufacturer_id, stock ) VALUES ( '#{@model_no}', #{@manufacturer_id}, #{@stock} ) RETURNING *;"
    @id = SqlRunner.run( sql )[0][ 'id' ].to_i
  end

  def self.get_many( sql )
    results = SqlRunner.run( sql )
    return results.map { |television| Television.new( television ) }
  end

  def delete()
    sql = "DELETE FROM televisions WHERE id = #{@id}"
    SqlRunner.run( sql )
  end

  def self.delete( id )
    sql = "DELETE FROM televisions where id = #{id}"
    SqlRunner.run( sql )
  end

  # def self.delete_all()
  #   sql = "DELETE FROM televisions;"
  #   SqlRunner.run( sql )
  # end

  def self.find( id )
    sql = "SELECT * FROM televisions WHERE id = #{id};"
    television = SqlRunner.run( sql )[0]
    return Television.new( television )
  end

  def self.all()
    sql = "SELECT * FROM televisions;"
    return Television.get_many( sql )
  end

  def manufacturer()
    sql = "SELECT * FROM manufacturers WHERE id = #{manufacturer_id}"
    manufacturer = SqlRunner.run( sql )[0]
    return Manufacturer.new( manufacturer )
  end

  def update()
    sql = "UPDATE televisions SET model_no = '#{@model_no}' WHERE id = #{@id};"
    SqlRunner.run( sql )
  end

  def update_model()
    sql = "SELECT model_temp FROM manufacturers WHERE id = #{@manufacturer_id};"
    @model_no = SqlRunner.run( sql )[0][ 'model_temp' ].to_s + "-" + @model_no
    update()
  end

end