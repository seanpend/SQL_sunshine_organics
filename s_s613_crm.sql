/*
	ICT211 Task 2 Database
    Author: Sean Sullivan
    ID: 113330
    SQL Workbench build: 8.0.23
*/

/* Drop Tables if exist */    
DROP TABLE IF EXISTS 
	cabinType, 
	cabin,
	workshop,
	message,
	booking,
	payment,
	businessDescription,
	gsoMember,
	customer;
    
/* Create table statements for all entitys and integrity constraints */

/* Business Description */
CREATE TABLE IF NOT EXISTS businessDescription (
	busID VARCHAR (30) NOT NULL,
    busName VARCHAR (30) NOT NULL,
    busAddress VARCHAR (100) NOT NULL,
    busEmail VARCHAR (50) NOT NULL,
    busPhone VARCHAR (20) NOT NULL,
    PRIMARY KEY (busID)
);

/* GSO Member */
CREATE TABLE IF NOT EXISTS gsoMember (
	memberID VARCHAR (30) NOT NULL,
    memberFname VARCHAR (30) NOT NULL,
    memberLname VARCHAR (30) NOT NULL,
    contactName VARCHAR (50) NOT NULL,
    joinDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    endDate DATETIME DEFAULT NULL,
    busID VARCHAR (30) NOT NULL,
    memberDescription VARCHAR (500),
    PRIMARY KEY (memberID),
    /* Constraints */
    CONSTRAINT fkBusID
		FOREIGN KEY (busID) REFERENCES businessDescription(busID)
			ON UPDATE CASCADE
			ON DELETE RESTRICT
);

/* Cabin Type */
CREATE TABLE IF NOT EXISTS cabinType (
	cabinName VARCHAR (25) NOT NULL,
	maxOccupancy INT (1) NOT NULL,
	cabinSize	INT (2) NOT NULL,
    cabinPrice DECIMAL (10, 2) NOT NULL,
    unitShippingCost DECIMAL (10, 2) NOT NULL,
	PRIMARY KEY (cabinName)
);

/* Cabin */
CREATE TABLE IF NOT EXISTS cabin (
	cabinID VARCHAR (30) NOT NULL,
    memberID VARCHAR (30) NOT NULL,
    cabinName VARCHAR (25) NOT NULL,
    cabinDescription VARCHAR (500),
    purchaseDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deliveryDate DATETIME NOT NULL,
    PRIMARY KEY (cabinID),
    /* Constraints */
    CONSTRAINT fkMemberID
		FOREIGN KEY (memberID) REFERENCES gsoMember(memberID)
			ON UPDATE CASCADE
			ON DELETE RESTRICT,
	CONSTRAINT fkCabinName
		FOREIGN KEY (cabinName) REFERENCES cabinType(cabinName)
);

/* Workshop */
CREATE TABLE IF NOT EXISTS workshop (
	workshopID VARCHAR (30) NOT NULL,
    memberID VARCHAR (30) NOT NULL,
    memberFullName VARCHAR(100) NOT NULL,
    workshopDescription VARCHAR (500),
    availableSpots SMALLINT NOT NULL,
    duration VARCHAR (30) NOT NULL,
    repetition VARCHAR (20),
    cost DECIMAL (10, 2) NOT NULL,
    PRIMARY KEY (workshopID),
    
    /* Constraints */
    CONSTRAINT fkWsMemberID
		FOREIGN KEY (memberID) REFERENCES gsoMember(memberID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

/* Customer */
CREATE TABLE IF NOT EXISTS customer (
	customerID VARCHAR (30) NOT NULL,
    custFname VARCHAR (30) NOT NULL,
    custLname VARCHAR (30) NOT NULL,
    custEmail VARCHAR (50) NOT NULL,
    custAddress VARCHAR (100),
    custPhone VARCHAR (20) NOT NULL,
    PRIMARY KEY (customerID)
    /* Constraints */
);

/* Booking */
CREATE TABLE IF NOT EXISTS booking (
	bookingID VARCHAR (30) NOT NULL,
    workshopID VARCHAR (30) NOT NULL,
    customerID VARCHAR (30) NOT NULL,
    bookingDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    workshopDate DATETIME NOT NULL,
    PRIMARY KEY (bookingID),
    /* Constraints */
    CONSTRAINT fkBkWorkshopID
		FOREIGN KEY (workshopID) REFERENCES workshop(workshopID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
	CONSTRAINT fkBkCustomerID
		FOREIGN KEY (customerID) REFERENCES customer(customerID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

/* Payment */
CREATE TABLE IF NOT EXISTS payment (
	paymentID VARCHAR (30) NOT NULL,
    customerID VARCHAR (30) NOT NULL,
    memberID VARCHAR (30) NOT NULL,
    payAmount DECIMAL (10, 2) NOT NULL,
    payDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payDescription VARCHAR (500),
    PRIMARY KEY (paymentID),
    /* Constraints */
    CONSTRAINT fkPayMemberID
		FOREIGN KEY (memberID) REFERENCES gsoMember(memberID)
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
	CONSTRAINT fkPayCustomerID
		FOREIGN KEY (customerID) REFERENCES customer(customerID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

/* Message */
CREATE TABLE IF NOT EXISTS message (
	messageID INTEGER NOT NULL AUTO_INCREMENT,
    memberID VARCHAR (30) NOT NULL,
    customerID VARCHAR (30) NOT NULL,
    /* The dateField is automatically updated to the current timestamp 
    of when the message is generated and sent to the GSO member and customer */
    dateField TIMESTAMP	NOT NULL DEFAULT CURRENT_TIMESTAMP,
    messageField VARCHAR (500),
    PRIMARY KEY (messageID),
    /* Constraints */
	CONSTRAINT fkMsgCustomerID
		FOREIGN KEY (customerID) REFERENCES customer(customerID)
        ON UPDATE CASCADE 
        ON DELETE RESTRICT,
	CONSTRAINT fkMsgMemberID
		FOREIGN KEY (memberID) REFERENCES gsoMember(memberID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

/* Trigger Statement */ 

/* Insert a message to Message table when customer order is placed */

DROP TRIGGER IF EXISTS afterOrderMessage;

DELIMITER //
CREATE TRIGGER afterOrderMessage
	AFTER  INSERT
	ON payment
	FOR EACH ROW
BEGIN
	INSERT INTO message ( memberID, customerID, messageField)
	VALUES (NEW.memberID, NEW.customerID, "Payment Recieved, Workshop has been booked.");
END//

DELIMITER ;

/* INSERT INTO statements */

/* Incorporate the exact 6 cabin types and the details given in Table 1 */

INSERT INTO cabinType (cabinName, maxOccupancy, cabinSize, cabinPrice, unitShippingCost)
VALUES	("Sunshine Cabin Ace", 2, 12, 9950.00, 400.00),
		("Sunshine Cabin Beta", 2, 15, 11250.00, 450.00),
		("Sunshine Cabin Gamma", 3, 21, 12550.00, 500.00),
		("Sunshine Cabin Delta", 4, 25, 15950.00, 550.00),
		("Sunshine Cabin Epsilon", 4, 30, 19950.00, 600.00),
		("Sunshine Cabin Zeta", 4, 36, 24550.00, 650.00);
        
/* Business Description. Business details will be made up for the GSO members */
INSERT INTO businessDescription (busID, busName, busAddress, busEmail, busPhone)
VALUES 	("bus12345", "Nambour Growers", "12 Parks Street, Nambour, 4222, Queensland", "rosemaryblack@nambourgrowers.com.au", "0422045504"),
		("bus54321", "Buderim Farm", "5 Stuart Street, Buderim, 4120, Queensland", "seansullivan@budfarm.com.au", "0445188373"),
        ("bus99882", "Noosa Organics", "36 Belle Avenue, Noosa, 4167, Queensland", "trentmyrtle@noosaorganics.com.au", "0445188373");

/* Incorporate the exact 3 GSO members whose names appear in Table 2 */
INSERT INTO gsoMember (memberID, memberFname, memberLname, contactName, joinDate, endDate, busID, memberDescription)
VALUES 	("member12345", "Rosemary", "Black", "Rosemary", "2021-02-05 13:00:00", NULL, "bus12345", "Rosemary specialises in 
		sustainable vegetable growth"),
		("member54321", "Sean", "Sullivan", "Sully", "2021-02-22 10:30:00", NULL, "bus54321", "Sully specialises in
        organic tomato growth"),
        ("member99882", "Trent", "Myrtle", "Trent", "2021-02-19 12:00:00", NULL, "bus99882", "Trent specialises in
        strawberry sustainable farm development");


/* Cabins that are purchased the cabinName references the specific details given in table 1 and
are supplied in the cabinTypes table above */
INSERT INTO cabin (cabinID, memberID, cabinName, cabinDescription, purchaseDate, deliveryDate)
VALUES 	("cabin11223", "member12345", "Sunshine Cabin Ace", "Small and quaint cabin", "2021-02-17 15:00:00", "2021-02-25 11:00:00"),
		("cabin13211", "member54321", "Sunshine Cabin Zeta", "Large luxury cabin", "2021-03-01 09:00:00", "2021-03-11 16:00:00"),
        ("cabin54123", "member99882", "Sunshine Cabin Delta", "Medium-sized cabin", "2021-03-01 09:00:00", "2021-03-11 16:00:00");
        

/* Incorporate the exact 6 workshop details given in Table 2 */
INSERT INTO workshop (workshopID, memberID, memberFullName, workshopDescription, availableSpots, duration, repetition, cost)
VALUES 	("ws12345", "member12345", "Rosemary Black", "Workshop focuses on organic vegetable growth", 25, "2 day", "Monthly", 450.00),
		("ws12346", "member12345", "Rosemary Black", "Workshop focuses on starting up home grown organic vegetables in your backyard", 
        39, "1 day", "Weekly", 250.00),
        ("ws54321", "member54321", "Sean Sullivan", "Workshop involves how to grow the perfect tomatoes", 10, "2 day", "Monthly", 500.00),
        ("ws54322", "member54321", "Sean Sullivan", "Workshop focuses on producing large scale tomatoe patches for farmers", 10, "4 hours", 
        "Fortnightly", 150.00),
        ("ws99882", "member99882", "Trent Myrtle", "Workshop involves small scale strawberry production", 24, "1 day", 
        "Monthly", 250.00),
        ("ws99883", "member99882", "Trent Myrtle", "Workshop focuses on large scale strawberry farm development", 11, "4 hour", 
        "Weekly", 150.00);

/* Create at least 6 customers, incorporate your tutor’s name into the
customer data */
INSERT INTO customer (customerID, custFname, custLname, custEmail, custAddress, custPhone)
VALUES 	("cus12345", "Judith", "Watson", "jwatson233@gmail.com.au", "12 Bark Street, Mooloolaba, 4112, Queensland", "04112345619"),
		("cus54321", "Allan", "Dews", "adew11@outlook.com.au", "3/7 Copper Avenue, Maroochydore, 4100, Queensland", "049873410"),
        ("cus11224", "Jake", "Roddick", "jrod121@outlook.com.au", "65 Hurst Street, Maroochydore, 4100, Queensland", "044736410"),
        ("cus42211", "Sarah", "Short", "short9876@gmail.com.au", "1 Alice Parade, Caloundra, 4150, Queensland", "044791279"),
        ("cus44553", "Joan", "Gouz", "jojo123@yahoo.com.au", "43 Cumberline Drive, Alexandra Heads, 4103, Queensland", "042788823"),
        ("cus66432", "Holly", "Hammersmith", "holz123@outlook.com.au", "120 Radley Street, Sippy Downs, 4105, Queensland", "044222289");


/*  Create workshop bookings for at least 6 customers
	Make sure that at least 3 customers make multiple bookings */
INSERT INTO booking (bookingID, customerID, workshopID, bookingDate, workshopDate)

		/* Customer Judith Watson Making multiple bookings */
VALUES 	("bk12345", "cus12345", "ws12345", "2021-03-15 11:00:00", "2021-03-20 09:30:00"),
		("bk12346", "cus12345", "ws12346", "2021-03-15 11:15:00", "2021-03-25 09:00:00"),
        /* Customer Allan Dews Making multiple bookings */
        ("bk54321", "cus54321", "ws54321", "2021-03-16 16:10:00", "2021-03-28 09:00:00"),
        ("bk54322", "cus54321", "ws12345", "2021-03-16 16:20:00", "2021-03-20 09:30:00"),
        /* Customer Jake Roddic making multiple bookings */
        ("bk32154", "cus11224", "ws12345", "2021-03-18 13:40:00", "2021-03-20 09:30:00"),
        ("bk32151", "cus11224", "ws54322", "2021-03-18 13:48:00", "2021-03-26 09:30:00"),
        /* Customer Sarah Short making a workshop booking */
        ("bk42211", "cus42211", "ws54322", "2021-03-01 12:15:00", "2021-03-26 09:30:00"),
        /* Customer Joan Gouz making a workshop booking*/
        ("bk44553", "cus44553", "ws99882", "2021-03-26 09:45:00", "2021-04-02 10:00:00"),
        /* Customer Holly Hammersmith making a booking */
        ("bk66432", "cus66432", "ws99883", "2021-04-10 17:10:00", "2021-04-25 10:30:00");
        
/* Payment for each customers workshop booking */
INSERT INTO payment (paymentID, customerID, memberID, payAmount, payDate, payDescription)
			/* Customer Judith Watsons payments to GSO member Rosemary Black	*/
VALUES 	("pay12345", "cus12345", "member12345", 450.00, "2021-03-15 11:00:00", "Amount of $450.00 has been paid to GSO Member"),
		("pay12346", "cus12345", "member12345", 250.00, "2021-03-15 11:15:00", "Amount of $250.00 has been paid to GSO Member"),
			/* Customer Allan Dews payments to GSO member's Sean Sullivan and Rosemary Black */
        ("pay54321", "cus54321", "member54321", 500.00, "2021-03-16 16:10:00", "Amount of $500.00 has been paid to GSO Member"),
        ("pay54322", "cus54321", "member12345", 450.00, "2021-03-16 16:20:00", "Amount of $450.00 has been paid to GSO Member"),
			/* Customer Jake Roddick payments to GSO member's Rosemary Black and Sean Sullivan */
        ("pay32154", "cus11224", "member12345", 450.00, "2021-03-18 13:40:00", "Amount of $450.00 has been paid to GSO Member"),
        ("pay32151", "cus11224", "member54321", 150.00, "2021-03-18 13:48:00", "Amount of $150.00 has been paid to GSO Member"),
			/* Customer Sarah Short payment to GSO member Sean Sullivan */
        ("pay42211", "cus42211", "member54321", 150.00, "2021-03-01 12:15:00", "Amount of $150.00 has been paid to GSO Member"),
			/* Customer Joan Gouz payment to GSO member Trent Myrtle */
        ("pay44553", "cus44553", "member99882", 250.00, "2021-03-26 09:45:00", "Amount of $250.00 has been paid to GSO Member"),
			/* Customer Holly Hammersmith payment to GSO member Trent Myrtle */
        ("pay66432", "cus66432", "member99882", 150.00, "2021-04-10 17:10:00", "Amount of $150.00 has been paid to GSO Member");
        
/*  PART C Select Statements  */
/* SELECT statement that will provide the 
following data for the customer with your tutor’s name:
Customer name and id
Booking date
Member id and business name
Workshop id, location, date and cost
Total cost of all workshops booked by the customer
Average cost of workshops booked */

CREATE VIEW CustomerReport as
SELECT CONCAT(cus.custFname, " ", cus.custLname),
    cus.customerID,
    bk.bookingDate,
    gso.memberID,
    bd.busName,
    ws.workshopID,
    bd.busAddress AS workshopLocation,
    bk.workshopDate,
    ws.cost,
    sum(py.payAmount),
    avg(py.payAmount)
FROM booking bk
JOIN customer cus on bk.customerID = cus.customerID
JOIN workshop ws on bk.workshopID = ws.workshopID
JOIN gsoMember gso on ws.memberID = gso.memberID
JOIN businessdescription bd on gso.busID = bd.busID
JOIN payment py on py.customerID = bk.customerID
WHERE CONCAT(cus.custFname, " ", cus.custLname) = "Judith Watson"
GROUP BY bk.bookingID;

/* Workshop booking report select statement with: 
List of all bookings made between a start and end date
GSO Member name and account number
Workshop ID, date, and the cost
Customer name, phone, and email
Grouped by GSO member and ordered in consecutive date order
 */
CREATE VIEW WorkshopBooking AS
SELECT 	CONCAT(memb.memberFname, " ", memb.memberLname) AS membFullName, 
		memb.memberID, 
		ws.workshopID, bk.workshopDate, ws.cost,
        CONCAT(cus.custFname, " ", cus.custLname) AS cusFullName,
        cus.custPhone, cus.custEmail
FROM 	customer cus
JOIN 	booking bk	ON bk.customerID = cus.customerID
JOIN 	workshop ws ON bk.workshopID = ws.workshopID
JOIN 	gsoMember memb	ON ws.memberID = memb.memberID
WHERE 	bk.workshopDate < "2021-09-20" 		
		AND
		bk.workshopDate > "2019-09-20"
ORDER BY memb.memberID, bk.workshopDate;
        






