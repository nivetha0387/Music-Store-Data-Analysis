create DATABASE music_store;
USE music_store;

-- 1. Genre and MediaType

CREATE TABLE Genre (
	genre_id INT PRIMARY KEY,
	name VARCHAR(120)
);
CREATE TABLE MediaType (
	media_type_id INT PRIMARY KEY,
	name VARCHAR(120)
);

-- 2. Employee
CREATE TABLE Employee (
	employee_id INT PRIMARY KEY,
	last_name VARCHAR(120),
	first_name VARCHAR(120),
	title VARCHAR(120),
	reports_to INT,
  levels VARCHAR(255),
	birthdate DATE,
	hire_date DATE,
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100)
);

-- 3. Customer
CREATE TABLE Customer (
	customer_id INT PRIMARY KEY,
	first_name VARCHAR(120),
	last_name VARCHAR(120),
	company VARCHAR(120),
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100),
	support_rep_id INT,
	FOREIGN KEY (support_rep_id) REFERENCES Employee(employee_id)
);

-- 4. Artist
CREATE TABLE Artist (
	artist_id INT PRIMARY KEY,
	name VARCHAR(120)
);

-- 5. Album
CREATE TABLE Album (
	album_id INT PRIMARY KEY,
	title VARCHAR(160),
	artist_id INT,
	FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
);

-- 6. Track
CREATE TABLE Track (
	track_id INT PRIMARY KEY,
	name VARCHAR(200),
	album_id INT,
	media_type_id INT,
	genre_id INT,
	composer VARCHAR(220),
	milliseconds INT,
	bytes INT,
	unit_price DECIMAL(10,2),
	FOREIGN KEY (album_id) REFERENCES Album(album_id),
	FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id),
	FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
);

-- 7. Invoice
CREATE TABLE Invoice (
	invoice_id INT PRIMARY KEY,
	customer_id INT,
	invoice_date DATE,
	billing_address VARCHAR(255),
	billing_city VARCHAR(100),
	billing_state VARCHAR(100),
	billing_country VARCHAR(100),
	billing_postal_code VARCHAR(20),
	total DECIMAL(10,2),
	FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

-- 8. InvoiceLine
CREATE TABLE InvoiceLine (
	invoice_line_id INT PRIMARY KEY,
	invoice_id INT,
	track_id INT,
	unit_price DECIMAL(10,2),
	quantity INT,
	FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);

-- 9. Playlist
CREATE TABLE Playlist (
 	playlist_id INT PRIMARY KEY,
	name VARCHAR(255)
);

-- 10. PlaylistTrack
CREATE TABLE PlaylistTrack (
	playlist_id INT,
	track_id INT,
	PRIMARY KEY (playlist_id, track_id),
	FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);

SELECT * FROM GENRE;
SELECT * FROM MEDIATYPE;
SELECT * FROM EMPLOYEE;
SELECT * FROM CUSTOMER;
SELECT * FROM ARTIST;
SELECT * FROM ALBUM;
SELECT * FROM TRACK;
SELECT * FROM INVOICE;
SELECT * FROM INVOICELINE;
SELECT * FROM PLAYLIST;
SELECT * FROM PLAYLISTTRACK;

-- 1. Who is the senior most employee based on job title? 
SELECT EMPLOYEE_ID,FIRST_NAME,TITLE, LEVELS
FROM EMPLOYEE
order by LEVELS ASC
LIMIT 1;

-- 2. Which countries have the most Invoices?
SELECT BILLING_COUNTRY,COUNT(INVOICE_ID) TOT_INV
FROM INVOICE
group  by BILLING_COUNTRY
order by TOT_INV DESC;

-- 3. What are the top 3 values of total invoice?
SELECT INVOICE_ID,TOTAL
FROM INVOICE
order by TOTAL DESC
limit 3;

/* 4. Which city has the best customers? - 
We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals
*/
select BILLING_CITY,sum(TOTAL) TOTAL_SALES
FROM INVOICE
group by BILLING_CITY
order by TOTAL_SALES desc
limit 1;

/*5. Who is the best customer? - 
The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money
*/
SELECT C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME,sum(I.TOTAL) TOTAL_SPENT
FROM CUSTOMER C
JOIN INVOICE I
ON C.CUSTOMER_ID = I.CUSTOMER_ID 
group by C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME
order by TOTAL_SPENT desc
LIMIT 1;

/*6. Write a query to return the email, first name, 
last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A
*/
SELECT distinct C.EMAIL,C.FIRST_NAME,C.LAST_NAME,G.NAME GENRE
FROM CUSTOMER C
JOIN INVOICE I
     ON C.CUSTOMER_ID = I.CUSTOMER_ID 
JOIN INVOICELINE IL
     ON I.INVOICE_ID = IL.INVOICE_ID
JOIN TRACK T
     ON IL.TRACK_ID = T.TRACK_ID
JOIN GENRE G
     ON T.GENRE_ID = G.GENRE_ID
WHERE G.NAME = 'Rock'
order by C.EMAIL ASC;

/*7. Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands 
*/
SELECT AR.NAME ARTIST_NAME,count(T.TRACK_ID) TOT_ROCK_TRACKS
FROM ARTIST AR
JOIN ALBUM AL
     ON AR.ARTIST_ID = AL.ARTIST_ID
JOIN TRACK T
     ON AL.ALBUM_ID = T.ALBUM_ID
JOIN GENRE G
     ON T.GENRE_ID = G.GENRE_ID
WHERE G.NAME = 'Rock'
group by AR.ARTIST_ID,AR.NAME
order by TOT_ROCK_TRACKS desc
limit 10;

/*8. Return all the track names that have a song length longer than the average song length.- 
Return the Name and Milliseconds for each track. Order by the song length, with the longest songs listed first
*/
SELECT NAME,MILLISECONDS
FROM TRACK
WHERE MILLISECONDS > (
                      SELECT avg(MILLISECONDS)
                      FROM TRACK
                      )
 order by MILLISECONDS DESC;                     

/*9. Find how much amount is spent by each customer on artists? 
Write a query to return customer name, artist name and total spent 
*/
SELECT concat(C.FIRST_NAME,' ',C.LAST_NAME) CUSTOMER_NAME,
       AR.NAME ARTIST_NAME,
       sum(IL.UNIT_PRICE * IL.QUANTITY) TOTAL_SPENT
FROM CUSTOMER C
JOIN INVOICE I
     ON C.CUSTOMER_ID = I.CUSTOMER_ID
JOIN INVOICELINE IL
     ON I.INVOICE_ID = IL.INVOICE_ID
JOIN TRACK T
     ON IL.TRACK_ID = T.TRACK_ID
JOIN ALBUM AL
     ON T.ALBUM_ID = AL.ALBUM_ID
JOIN ARTIST AR
     ON AL.ARTIST_ID = AR.ARTIST_ID
group by C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME,
         AR.ARTIST_ID,AR.NAME
order by TOTAL_SPENT desc;


/*10. We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases.
 Write a query that returns each country along with the top Genre. 
 For countries where the maximum number of purchases is shared, return all Genres
*/
WITH GENRE_SALES AS (
    SELECT I.BILLING_COUNTRY,G.NAME AS GENRE,COUNT(IL.INVOICE_LINE_ID) AS PURCHASES
    FROM INVOICE I
    JOIN INVOICELINE IL ON I.INVOICE_ID = IL.INVOICE_ID
    JOIN TRACK T ON IL.TRACK_ID = T.TRACK_ID
    JOIN GENRE G ON T.GENRE_ID = G.GENRE_ID
    GROUP BY I.BILLING_COUNTRY,G.GENRE_ID,G.NAME
),
RANKED_GENRES AS (
    SELECT BILLING_COUNTRY,GENRE,PURCHASES,
        RANK() OVER (
            PARTITION BY BILLING_COUNTRY
            ORDER BY PURCHASES DESC
        ) AS GENRE_RANK
    FROM GENRE_SALES
)
SELECT BILLING_COUNTRY,GENRE,PURCHASES
FROM RANKED_GENRES
WHERE GENRE_RANK = 1
ORDER BY BILLING_COUNTRY;

/*11. Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount
*/
WITH CUSTOMER_SPENDING AS (
    SELECT I.BILLING_COUNTRY,C.CUSTOMER_ID,
    CONCAT(C.FIRST_NAME, ' ', C.LAST_NAME) AS CUSTOMER_NAME,
        SUM(I.TOTAL) AS TOTAL_SPENT
    FROM CUSTOMER C
    JOIN INVOICE I
        ON C.CUSTOMER_ID = I.CUSTOMER_ID
    GROUP BY I.BILLING_COUNTRY,C.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME
),
RANKED_CUSTOMERS AS (
    SELECT BILLING_COUNTRY,CUSTOMER_ID,CUSTOMER_NAME,TOTAL_SPENT,
        RANK() OVER (
            PARTITION BY BILLING_COUNTRY
            ORDER BY TOTAL_SPENT DESC
        ) AS CUSTOMER_RANK
    FROM CUSTOMER_SPENDING
)
SELECT BILLING_COUNTRY,CUSTOMER_NAME,TOTAL_SPENT
FROM RANKED_CUSTOMERS
WHERE CUSTOMER_RANK = 1
ORDER BY BILLING_COUNTRY;


