  -- The QuranDB Project
-- Author: Sami M
-- This script will create a table for the words of the Quran then populate it from the !!already existing!! [Quran]  table created in the earlier steps.
-- If you do not know what is going on and this is the first file you openned, then simply run CreateInsertScript.sql prior to running this, you should 
-- end up with two tables [Quran] containing the Surah/Chapter numbers and Ayah/Verses of the Quran, plus the table generated by this script which is a table of 
-- all words of the Quran listed by Sura/Chapter and Ayah/Verse



USE [yourDB]
GO

/****** Object:  Table [dbo].[QuranWord]    Script Date: 03/25/2013 15:25:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[QuranWord](
	[WordID] [int] IDENTITY(1,1) NOT NULL,
	[SuraID] [tinyint] NOT NULL,
	[VerseID] [smallint] NOT NULL,
	[Word] [nchar](256) NOT NULL
) ON [PRIMARY]

GO


declare @tmpAyah nvarchar(max)
declare @tmpWord nvarchar(128)
declare @sid int, @vid int
			DECLARE @S varchar(max),
			  @Split char(1),
			  @X xml
declare c cursor for
  SELECT suraid,verseid,ayahTextNoTashkil
  FROM [Quran]
open c
fetch next from c into @sid,@vid,@tmpAyah
   WHILE @@FETCH_STATUS = 0
	BEGIN
			SELECT @S = LTRIM(RTRIM(@tmpAyah)), @Split = ' '
			SELECT @X = CONVERT(xml,'<root><s>' + REPLACE(@S,@Split,'</s><s>') + '</s></root>')
				declare cc cursor for
									SELECT [Value] = T.c.value('.','varchar(20)')
									FROM @X.nodes('/root/s') T(c)
				open cc
				fetch next from cc into @tmpWord
				   WHILE @@FETCH_STATUS = 0
					BEGIN
					--select @sid,@vid,@tmpWord
					insert into [QuranWord]  (SuraID, VerseID, Word) values (@sid, @vid, @tmpWord)
					fetch next from cc into @tmpWord
					END
					close cc 
					deallocate cc	
	   fetch next from c into @sid,@vid,@tmpAyah
	END
close c 
deallocate c	

GO


