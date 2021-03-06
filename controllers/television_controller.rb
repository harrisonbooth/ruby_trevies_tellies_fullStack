require( 'sinatra' )
require( 'sinatra/contrib/all' )
require( 'pry' )
require_relative( '../models/television.rb')
require_relative( '../models/manufacturer.rb')
require_relative( './shared_functions.rb')

# get index televisions
get( '/televisions' ) do
  @televisions = Television.all().sort { |tele1, tele2| tv_sort_criteria(tele1, tele2) }

  @manufacturers = Manufacturer.all()
  erb( :"television/index" )
end

# get new television form
get( '/televisions/new' ) do
  @manufacturers = Manufacturer.all()
  erb( :"television/new" )
end

# post create television
post( '/televisions' ) do
  @television = Television.new( params )
  @television.save()
  redirect to( '/televisions' )
end

# post delete television
post( '/televisions/:id/delete' ) do
  Television.delete( params[ :id ] )
  redirect to( '/' )
end

# get order television form
get( '/televisions/:id/order') do
  @television = Television.find( params[ :id ] )
  erb( :"television/order" )
end

# post update television stock
post( '/televisions/:id/update' ) do
  current_television = Television.find( params[ :id ] )
  current_television.update_stock( params[ :stock ].to_i )
  redirect to( '/televisions' )
end

# post sell television
post( '/televisions/:id/sell') do
  @television = Television.find( params[ :id ] )
  @television.sell( 1 )
  @television.update()
  redirect to( '/televisions' )
end

# get set filter criteria
get( '/televisions/filter') do
  @manufacturer_id = params[ :manufacturer_id ]
  redirect to( "/televisions/filter/#{ @manufacturer_id }" )
end

# get filtered index
get( '/televisions/filter/:id') do
  @manufacturer = Manufacturer.find( params[ :id ] )
  @televisions = @manufacturer.televisions().sort { |tele1, tele2| tv_sort_criteria( tele1, tele2 ) }

  erb( :"television/filtered_index" )
end
