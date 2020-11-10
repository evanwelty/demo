select state
    , count (distinct vanid) as total_vr
    ,canvassmonth
 
    
  from (
    select t.vanid
      , split_part(surveyquestionname, ' ', 1) as state
      , surveyresponsename as turf
      , date_trunc('month', d.datecanvassed) as canvassmonth
      
      
        --Subtract 1 so Monday report pulls previous week
    from (
      --Get all VR vanids, most recent response for turf, and date updated
      --Limit by cycle and phase start date
      select c.vanid
        , sq.surveyquestionname
        , sr.surveyresponsename
        , row_number() over (partition by c.vanid order by c.datecanvassed desc) as row
        , c.datecanvassed
        , current_timestamp AT TIME ZONE 'PST' as time
      from van.tsm_nextgen_contactssurveyresponses_vr c
      left join van.tsm_nextgen_surveyquestions sq using(surveyquestionid)
      left join van.tsm_nextgen_surveyresponses sr using(surveyresponseid)
      where sq.surveyquestiontype='Affiliation'
        and (sq.cycle=2020 or sq.cycle=2019)
        and sq.surveyquestionname ilike '%Turf%'
      	and date(datemodified)<=date('10-15-2020')
        
    ) t
    left join (
      --Get the date this record was originally canvassed
      --This is to fix the issue of later updates/corrections adding a contact to the record
      select vanid
        , datecanvassed
        , row_number() over (partition by vanid order by datecanvassed asc) as row
      from van.tsm_nextgen_contactssurveyresponses_vr
    ) d using(vanid)
    where t.row=1
      and d.row=1
  ) a 
 where state = 'NV'
 Group by state, canvassmonth
 Order by canvassmonth asc
