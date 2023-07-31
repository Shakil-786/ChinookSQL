select * from Album; -- 347
select * from Artist; -- 275
select * from Customer; -- 59
select * from Employee; -- 8
select * from Genre; -- 25
select * from Invoice; -- 412
select * from InvoiceLine; -- 2240
select * from MediaType; -- 5
select * from Playlist; -- 18
select * from PlaylistTrack; -- 8715
select * from Track; -- 3503

--1) Find the artist who has contributed with the maximum no of songs. Display the artist name and the no of albums.


with cte as(
SELECT  ar.Name as artist_name, COUNT(a.AlbumId) as no_of_track, rank() over(order by Count(1) desc) as ran from Track t  inner join album a on t.AlbumId=a.AlbumId  inner join artist ar on a.ArtistId=ar.ArtistId GROUP by ar.Name)

select * from cte where ran=1


--2) Display the name, email id, country of all listeners who love Jazz, Rock and Pop music.


select * from Customer; -- 59
select * from Genre; -- 25
select * from Track; -- 3503
select * from Invoice; -- 412
select * from InvoiceLine; -- 2240

SELECT distinct g.Name,(c.FirstName+' '+c.LastName) as name_of_customer ,c.Email,c.Country from genre g inner join Track t on g.GenreId=t.GenreId inner join InvoiceLine il on il.TrackId=t.TrackId inner join invoice i on i.InvoiceId=il.InvoiceId inner join Customer c on c.CustomerId=i.CustomerId where g.Name in('Jazz','Rock','Pop');


with cte as(
SELECT distinct g.Name,(c.FirstName+' '+c.LastName) as name_of_customer ,c.Email,c.Country from genre g inner join Track t on g.GenreId=t.GenreId inner join InvoiceLine il on il.TrackId=t.TrackId inner join invoice i on i.InvoiceId=il.InvoiceId inner join Customer c on c.CustomerId=i.CustomerId where g.Name in('Jazz','Rock','Pop') 

)
select name_of_customer, count(Name) as cnt from cte group by name_of_customer  having COUNT(name)=3


--3) Find the employee who has supported the most no of customers. Display the employee name and designation


select * from Customer; -- 59
select * from Employee; -- 8

with cte as(
SELECT SupportRepId as emoplyee_id, COUNT(CustomerId)  as help from Customer GROUP by SupportRepId )

SELECT top 1 (e.FirstName+' '+e.LastName) as Employee_name, e.Title,c.help from Employee e inner join cte c on e.EmployeeId=c.emoplyee_id ORDER by c.help desc


--4) Which city corresponds to the best customers?

select * from Customer; -- 59
select * from Invoice; -- 412

SELECT top 10 c.City, sum(i.total) as total_spend  from Customer c inner join invoice i on c.CustomerId=i.CustomerId GROUP  by c.city order by total_spend DESC


--5) The highest number of invoices belongs to which country?

select * from Customer; -- 59
select * from Invoice; -- 412


SELECT   c.Country,count(i.InvoiceId) as Total_invoice from Customer c inner join invoice i on c.CustomerId=i.CustomerId GROUP by c.Country ORDER by Total_invoice desc 


--6.Name the best customer (customer who spent the most money).

SELECT  top 1 (c.FirstName+' '+c.LastName) as customer_name,sum(i.Total) as total_spend
 from customer c 
 inner join invoice i on c.CustomerId=i.CustomerId 
 GROUP by (c.FirstName+' '+c.LastName)  
 order by sum(i.Total) desc


--7) Suppose you want to host a rock concert in a city and want to know which location should host it.

select * from Artist;
select * from Customer; -- 59
select * from Genre; -- 25
select * from Track; -- 3503
select * from Invoice; -- 412
select * from InvoiceLine; -- 2240


SELECT  g.Name as genre_name,c.City,c.Country,sum(i.Total) as total_spend,ar.Name as artitst_name,COUNT(g.Name) as type from Genre g 
inner join Track t on g.GenreId=t.GenreId
inner join InvoiceLine il on il.TrackId=t.TrackId
inner join Invoice i on i.InvoiceId=il.InvoiceId
inner join Customer c on c.CustomerId=i.CustomerId
inner join Album a on a.AlbumId=t.AlbumId
inner join Artist ar on ar.ArtistId=a.ArtistId
where g.Name='Rock'
GROUP by c.City,c.Country,g.Name, ar.Name
order by type desc



--8) Identify all the albums who have less then 5 track under them.

select * from Album; -- 347
select * from Track; -- 3503


SELECT a.AlbumId,a.Title,count(t.TrackId) as total_track 
from Album a 
inner join Track t on a.AlbumId=t.AlbumId
GROUP by a.AlbumId,a.Title
HAVING COUNT(t.TrackId)<=5


--9) Display the track, album, artist and the genre for all tracks which are not purchased.

select * from Album; -- 347
select * from Track; -- 3503
SELECT * from Artist;
SELECT * from Genre;
SELECT * from InvoiceLine;

SELECT t.Name,a.Title,ar.Name,g.Name 
from Album  a 
inner join Track t on a.AlbumId=t.AlbumId
inner join Artist ar on ar.ArtistId=a.ArtistId
inner join Genre g on g.GenreId=t.GenreId
LEFT JOIN InvoiceLine il on t.TrackId=il.TrackId 
where il.InvoiceId is null



--10) Find artist who have performed in multiple genres. Diplay the aritst name and the genre.

select * from Track; -- 3503
SELECT * from Artist;
SELECT * from Genre;
SELECT * from Album;


with cte as(

SELECT distinct ar.Name as artist_name,g.Name
 FROM Genre g 
inner join Track t on g.GenreId=t.GenreId
inner join  Album a on a.AlbumId=t.AlbumId
inner join Artist ar on a.ArtistId=ar.ArtistId ),
cte1 as(
SELECT artist_name,COUNT(artist_name) as count_album from cte 
group by artist_name
having COUNT(artist_name)>=2
)
SELECT c.artist_name,c.name
from cte1 c1 
inner join cte c on c.artist_name=c1.artist_name;

SELECT g.Name,count(distinct ar.Name) as cnt
 FROM Genre g 
inner join Track t on g.GenreId=t.GenreId
inner join  Album a on a.AlbumId=t.AlbumId
inner join Artist ar on a.ArtistId=ar.ArtistId
group by g.Name
having count( ar.name)>=2







--11) Which is the most popular and least popular genre? (Popularity is defined based on how many times it has been purchased.)

SELECT * from Genre;
SELECT * from Track;
SELECT * from Invoice;
SELECT * from InvoiceLine;

with cte as(
SELECT  g.Name, COUNT(il.Quantity) as total_pur  from Genre g
inner join Track t on g.GenreId=t.GenreId
inner join InvoiceLine il on il.TrackId=t.TrackId
GROUP by g.Name ),
cte1 as(
SELECT *,RANK() over(order by total_pur desc) as rn from cte),
cte2 as(SELECT *,RANK() over(order by total_pur) as rn from cte)

SELECT * from cte1 c where c.rn=1 UNION SELECT* from cte2 c2 where c2.rn=1;



--12) Identify if there are tracks more expensive than others. If there are then display the track name along with the album title and artist name for these expensive tracks.


SELECT t.Name as track_name,a.Title as Album_title, ar.Name as Artist_name,t.UnitPrice as price
 FROM Track t 
 inner join Album a on a.AlbumId=t.AlbumId
 inner join Artist ar on ar.ArtistId=a.ArtistId
 where UnitPrice >  (select avg(UnitPrice) from track);




--13) Identify the 5 most popular artist for the most popular genre. Display the artist name along with the no of songs. (Popularity is defined based on how many songs an artist has performed in for the particular genre.)



with cte as(
SELECT g.GenreId as id, g.Name,COUNT(1) as total_track, RANK() over(order by count(t.name) desc) as rn from  Track t 
INNER JOIN Genre g on g.GenreId=t.GenreId
INNER join InvoiceLine il on il.TrackId=t.TrackId
GROUP by g.Name,g.GenreId)


select  top 5 g.Name as genre_name,ar.Name as artist_name,COUNT(t.Name) as track_count 
from Artist ar 
INNER join Album a on ar.ArtistId=a.ArtistId
INNER JOIN Track t on t.AlbumId=a.AlbumId
INNER JOIN Genre g on g.GenreId=t.GenreId
where g.Name=(select name From cte where rn=1)
GROUP by g.name, ar.Name
ORDER BY COUNT(t.Name) desc;






with cte as(
select g.GenreId,g.Name as genre_name,count(1) as no_of_purchase,RANK() over(order by count(1) desc) as rn
from InvoiceLine il
join track t on t.TrackId=il.TrackId
join Genre g on g.GenreId=t.GenreId
group by g.GenreId,g.Name),
cte1 as(
select GenreId,genre_name from cte where rn=1),
cte2 as(
select ar.name as artist_name,c.genre_name as genre,count(1) as no_of_song,rank() over(order by count(1) desc) rnk
from Track t
join album al on t.AlbumId=al.AlbumId
join Artist ar on ar.ArtistId=al.ArtistId
join cte1 c on c.GenreId=t.GenreId
group by ar.name,c.genre_name)
select artist_name,genre,no_of_song
from cte2
where rnk<=5;




SELECT genre.name,
       COUNT(*) AS track_count,
       REPLICATE('■■', (100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()) ) AS pct,
       REPLICATE('**', (100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()) ) as pct1
FROM genre
LEFT JOIN track ON genre.genreid = track.genreid
GROUP BY genre.name
ORDER BY track_count desc;

