with repos as (
select   xmlelement(name Repository, xmlattributes( id as id, 
													name as name, 
													timestamp as timestamp,
													(
													   with test as (
															select unnest(xpath('/*/*',result_xml)) as x
															  from log
															 where repo_id = repositories.id
															)
															select count(*)
															  from test
													) as tot,
													(
													   with test as (
															select unnest(xpath('/*/*',result_xml)) as x
															  from log
															 where repo_id = repositories.id
															)
															select coalesce(sum(case when (xpath('@status',x))[1]::varchar = 'OK' then 1 else 0 end),0)
															  from test
													) as ok),
			       (
			          select xmlelement(name root, xmlattributes(testfile_path as testfile_path), xmlagg(result_xml))
			            from log
			           where repo_id = repositories.id
			           group by testfile_path
			       )) as x
  from repositories
 where (name, timestamp) in (
   select name, max(timestamp)
    from repositories
   group by 1
   order by name
 )
)
select xmlelement(name root, xmlagg(x))::varchar
  from repos
