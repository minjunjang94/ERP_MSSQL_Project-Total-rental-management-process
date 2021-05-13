IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseStuffRegQuery' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseStuffRegQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ빰�ǵ��_minjun : ��ȸ
 �ۼ��� - '2020-04-21
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseStuffRegQuery
    @xmlDocument    NVARCHAR(MAX)           -- Xml������
   ,@xmlFlags       INT             = 0     -- XmlFlag
   ,@ServiceSeq     INT             = 0     -- ���� ��ȣ
   ,@WorkingTag     NVARCHAR(10)    = ''    -- WorkingTag
   ,@CompanySeq     INT             = 1     -- ȸ�� ��ȣ
   ,@LanguageSeq    INT             = 1     -- ��� ��ȣ
   ,@UserSeq        INT             = 0     -- ����� ��ȣ
   ,@PgmSeq         INT             = 0     -- ���α׷� ��ȣ
AS
    -- ��������
    DECLARE @docHandle      INT
           ,@LeaseStuffSeq  INT
  
    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @LeaseStuffSeq       = ISNULL(LeaseStuffSeq       ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH (LeaseStuffSeq        INT) --�ʵ� ��� ������ Ÿ���� ������� �Ѵ�.
    
    -- ����Select
    SELECT   A.LeaseStuffName
            ,A.Area
            ,A.LeaseStuffSeq


     FROM	minjun_TACLeaseStuff		    AS A	WITH(NOLOCK)

     WHERE  A.CompanySeq          = @CompanySeq
  
RETURN