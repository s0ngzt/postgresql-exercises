-- 01 Insert some data into a table
/* data
 facid: 9, 
 Name: 'Spa', 
 membercost: 20, 
 guestcost: 30, 
 initialoutlay: 100000, 
 monthlymaintenance: 800.*/
insert into cd.facilities
values(9, 'Spa', 20, 30, 100000, 800);
-- 02 Insert multiple rows of data into a table
insert into cd.facilities
values(9, 'Spa', 20, 30, 100000, 800),
    (10, 'Squash Court 2', 3.5, 17.5, 5000, 80);
-- 03 Insert calculated data into a table
insert into cd.facilities (
        facid,
        name,
        membercost,
        guestcost,
        initialoutlay,
        monthlymaintenance
    )
select (
        select max(facid)
        from cd.facilities
    ) + 1,
    'Spa',
    20,
    30,
    100000,
    800;
-- 04 Update some existing data
update cd.facilities
set initialoutlay = 10000
where facid = 1;
-- 05 Update multiple rows and columns at the same time
update cd.facilities
set guestcost = 30,
    membercost = 6
where facid in (0, 1);
-- 06 Update a row based on the contents of another row
update cd.facilities facs
set membercost = (
        select membercost * 1.1
        from cd.facilities
        where facid = 0
    ),
    guestcost = (
        select guestcost * 1.1
        from cd.facilities
        where facid = 0
    )
where facs.facid = 1;
-- 07 Delete all bookings
delete from cd.bookings;
-- 08 Delete a member from the cd.members table
delete from cd.members
where memid = 37;
-- 09 Delete based on a subquery
delete from cd.members
where memid not in (
        select memid
        from cd.bookings
    );