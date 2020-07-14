--this script creates a stored procedure that stores tweets in the database
--the sproc is called by a python script upstream that gets the tweet data
--if the tweet record exists, update the record with new like/fav counts
--otherwise, insert the new tweet data

create procedure dbo.store_tweet
	@tweet_text varchar(max)
	,@tweet_score int
	,@favorite_count int
	,@reply_to_screenname varchar(255) = NULL
	,@create_date varchar(64)
	,@reply_to_sid varchar(255) = NULL
	,@tweet_id varchar(255)
	,@reply_to_uid varchar(255) = NULL
	,@screenname varchar(255)
	,@retweet_count int
	,@brand varchar(255)
	,@twitter_user_id varchar(100)
	,@tweet_source varchar(max)
	,@is_quote int
	,@hashtags varchar(max) = NULL
	
as

set nocount on;

if @screenname is null or @tweet_id is null
begin
	return -1;
end;

--check to see if we already have data for this tweet
declare @exists int;
select
	@exists = count(*)
from tower..fact_tweets t
where t.tweet_id=@tweet_id;

if @exists >= 1
begin
	--update data for this tweet
	--likely we have new counts for retweets and favorites
	update tower..fact_tweets
	set
		last_updated=getutcdate()
		,favorite_count=@favorite_count
		,retweet_count=@retweet_count
	where tweet_id=@tweet_id;
	end
	
	if @exists = 0
	begin
		--insert the new tweet
		insert into tower..fact_tweets (
			tweet_text
		,tweet_score
		,favorite_count
		,reply_to_screenname
		,create_date
		,reply_to_sid
		,tweet_id
		,reply_to_uid
		,screenname
		,retweet_count
		,brand
		,twitter_user_id
		,tweet_source
		,is_quote
		,hashtags
		)
		values (
			@tweet_text
		,@tweet_score
		,@favorite_count
		,@reply_to_screenname
		,@create_date
		,@reply_to_sid
		,@tweet_id
		,@reply_to_uid
		,@screenname
		,@retweet_count
		,@brand
		,@twitter_user_id
		,@tweet_source
		,@is_quote
		,@hashtags
		);
	end
