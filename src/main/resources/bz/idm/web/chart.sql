with
   days as (
      select now()::date - generate_series(0,30) as day
   ),
   rows as (
      select day, start, tot, ok, count(*) over(partition by day order by start desc) n_test
      from days
         left join test_session s
            on s.start::date = days.day
         left join lateral (
               select coalesce(sum((xpath('count(*)',result_xml))[1]::varchar::int),0) as tot,
                      coalesce(sum((xpath('count(*[@status="OK"])',result_xml))[1]::varchar::int),0) as ok
               from repositories r
                  join log l
                     on l.repo_id = r.id
                        and l.result_xml is not null
               where r.test_session_id = s.id )t
            on true
    ),
    rows_json as (
       select json_build_object('day', day, 'tot', sum(tot), 'ok', sum(ok)) as j
       from rows
       where n_test = 1
       group by day
       order by day asc
    )
 select json_agg(j)
 from rows_json