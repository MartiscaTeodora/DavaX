-- AND type='muder'
--
SELECT * from crime_scene_report  c
where ( c.city='SQL City' AND c."TYPE"='murder' AND c."DATE"='20180115');

--Security footage shows that there were 2 witnesses. The first witness lives at the last house on "Northwestern Dr". \
--The second witness, named Annabel, lives somewhere on "Franklin Ave".

SELECT * from crime_scene_report  c
where ( c.city='SQL City')

SELECT * from person p
where  p.address_street_name='Franklin Ave'  AND p.name LIKE '%Annabel%'--or p.address_street_name='Northwestern Dr'
--order by p.adress_number DESC()
--16371	Annabel Miller	490173	103	Franklin Ave	318771143  


SELECT * from person p
where  p.address_street_name='Northwestern Dr' order by p."ADDRESS_NUMBER" DESc

--14887	Morty Schapiro	118009	4919	Northwestern Dr	111564949 
SELECT * from interview
where person_id=14887 or person_id=16371

/*14887	I heard a gunshot and then saw a man run out. 
He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z". 
Only gold members have those bags. The man got into a car with a plate that included "H42W".
16371	I saw the murder happen,
and I recognized the killer from my gym when I was working out last week on January the 9th.
*/
SELECT * from get_fit_now_member
where id='48Z'

SELECT p.name, gfm.membership_status, d.id from drivers_license d
 join get_fit_now_member gfm on gfm.person_id= d.id 
 join person p on p.id=d.id
where plate_number like '%H42W%'

select person_id ,p. name, p.license_id
from get_fit_now_member gf
join person p on  gf.person_id = p.id
join drivers_license d on p.license_id=d.id
where membership_status='gold' and membership_start_date<20180901 and plate_number like '%H42W%'

67318	Jeremy Bowers	423327

SELECT * from interview
where person_id=67318

/*I was hired by a woman with a lot of money. I don't know her name but I know
she's around 5'5" (65") or 5'7" (67"). She has red hair and she drives a Tesla Model S.
I know that she attended the SQL Symphony Concert 3 times in December 2017.
*/

--918773	48	65	black	red	female	917UU3	Tesla	Model S
SElect p.id, p.name from drivers_license d
join person p on  p.license_id=d.id
--join facebook_event_checkin f on f.person_id=p.id
where car_make like '%Tesla%' and car_model='Model S' and gender = 'female' and hair_color='red' --and (height='65' OR height='67')
--and event.name=
--78881	Red Korb
SELECT * from interview
where person_id=78881

select   from facebook_event_checkin 
where event_name='SQL Symphony Concert' and "DATE" like '201712%' 
and person_id in(78881, 90700, 99716)


SELECT * from person
where id=99716

