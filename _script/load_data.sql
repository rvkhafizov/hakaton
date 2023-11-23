declare @path_file nvarchar(100)

declare @command nvarchar(max)

declare @counter int 
set @counter=1
while (@counter <= 7543)
begin
	set @path_file = N'F:\_обучение\hakaton\data\'+cast(@counter as varchar(100))+'.json'
	
	declare @result int
    exec master.dbo.xp_fileexist @path_file, @result output

	print @path_file

	if @result = 1
	begin
		set @command = 
			N' declare @JSON nvarchar(max) 
			   select @JSON = convert(nvarchar(max), coalesce(BulkColumn,'''' collate Cyrillic_General_100_CI_AS_SC_UTF8)) collate Cyrillic_General_CI_AS
               from openrowset(bulk ''' + @path_file +''', single_blob, codepage = ''65001'') json  

			   insert into dbo.buf
					   (deactivated
					   ,country_id
					   ,country_title
					   ,city_id
					   ,city_title
					   ,about
					   ,activities
					   ,books
					   ,games
					   ,interests
					   ,education_form
					   ,education_status
					   ,university
					   ,university_name
					   ,faculty
					   ,faculty_name
					   ,graduation)
				SELECT  

					deactivated, 
					country_id,
					country_title,
					city_id,
					city_title,
					about, 
					activities, 
					books, 
					games, 
					interests,
					education_form, 
					education_status, 
					university, 
					university_name, 
					faculty, 
					faculty_name,
					graduation

				FROM OPENJSON (@JSON,''$.response'') 
				With (deactivated nvarchar(50), 
					  country_id nvarchar(50) ''$.country.id'',
					  country_title nvarchar(50) ''$.country.title'',
					  city_id nvarchar(50) ''$.city.id'',
					  city_title nvarchar(50) ''$.city.title'',
					  about nvarchar(4000), 
					  activities nvarchar(4000), 
					  books nvarchar(4000), 
					  games nvarchar(4000), 
					  interests nvarchar(4000),
					  education_form nvarchar(4000), 
					  education_status nvarchar(4000), 
					  university nvarchar(4000), 
					  university_name nvarchar(4000), 
					  faculty nvarchar(4000), 
					  faculty_name nvarchar(4000),
					  graduation varchar(4000)) as Dataset'

		exec sp_executesql @command
	end

	set @counter  = @counter  + 1
end
