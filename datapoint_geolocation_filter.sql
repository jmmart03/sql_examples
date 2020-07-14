--this query identifies any data points that fall outside a given range of certain key geolocations

select distinct
  p.value
  ,t.id as 'event_id'
  ,g.lat as 'value_lat'
  ,g.lng as 'value_long'
  ,b.latitude as 'key_lat'
  ,b.longitude as 'key_long'
  ,b.distance_in_miles
  ,case when t.id=1 and b.distance_in_miles>3
    or t.id=2 and b.distance_in_miles>10
    or t.id=3 and b.distance_in_miles>50
   then 'outside'
   else 'inside'
   end as 'geoloc_status'
from tower..dim_value p
  join tower..dim_value_geoloc g on g.streetaddress=p.streetaddress and g.city=p.city and g.zip=p.zip
  join tower..dim_event t on t.id=p.event_id
  cross apply (
    select
      l.*
      ,l.geoloc.STDistance(g.geoloc)/1609.344 as 'distance_in_miles'
     from tower..dim_event_geoloc l
     where l.geoloc.STDistance(g.geoloc) is not null
      and l.eventid=t.id
      ) b
