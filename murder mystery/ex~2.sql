SELECT
  (SELECT COUNT(*) FROM CRIME_SCENE_REPORT) crime_scene_report_count, --1228
  (SELECT COUNT(*) FROM DRIVERS_LICENSE) drivers_license_count, --10007
  (SELECT COUNT(*) FROM FACEBOOK_EVENT_CHECKIN) facebook_event_checkin_count, --20011
  (SELECT COUNT(*) FROM INTERVIEW) interview_count, --4991
  (SELECT COUNT(*) FROM GET_FIT_NOW_MEMBER) get_fit_now_member_count,  --184
  (SELECT COUNT(*) FROM GET_FIT_NOW_CHECK_IN) get_fit_now_check_in_count, --2703
  (SELECT COUNT(*) FROM INCOME) income_count, --7514
  (SELECT COUNT(*) FROM PERSON) person_count --10011
FROM dual;
      
 
