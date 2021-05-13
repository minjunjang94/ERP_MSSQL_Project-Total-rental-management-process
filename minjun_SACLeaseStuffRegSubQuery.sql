IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseStuffRegSubQuery' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseStuffRegSubQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ빰�ǵ��_minjun : ������ȸ
 �ۼ��� - '2020-04-21
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseStuffRegSubQuery
    @xmlDocument    NVARCHAR(MAX)          -- Xml������
   ,@xmlFlags       INT            = 0     -- XmlFlag
   ,@ServiceSeq     INT            = 0     -- ���� ��ȣ
   ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
   ,@CompanySeq     INT            = 1     -- ȸ�� ��ȣ
   ,@LanguageSeq    INT            = 1     -- ��� ��ȣ
   ,@UserSeq        INT            = 0     -- ����� ��ȣ
   ,@PgmSeq         INT            = 0     -- ���α׷� ��ȣ
AS
    -- ��������
    DECLARE @docHandle           INT
           ,@LeaseStuffSeq       INT
  
    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT @LeaseStuffSeq         = RTRIM(LTRIM(ISNULL(LeaseStuffSeq          , 0)))
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH (LeaseStuffSeq        INT)
    
    -- ����Select
    SELECT	 
            
             A.LeaseStuffLocName                                            --�Ӵ���ġ	
            ,A.PrivateExtentM                                               --�������(m2)
            ,A.SharingExtentM                                               --��������(m2)	
            ,A.PrivateExtentP                                               --�������(��)
            ,A.SharingExtentP                                               --��������(��)	
            ,(A.PrivateExtentM + A.SharingExtentM)   AS   Total_M2
            ,(A.PrivateExtentP + A.SharingExtentP)   AS   Total_
            ,A.Remark                                                       --���		
            ,A.LeaseStuffSerl                                               --����		

								
    FROM    minjun_TACLeaseStuffLoc               AS  A   WITH(NOLOCK)

    WHERE   A.CompanySeq       = @CompanySeq
      AND   A.LeaseStuffSeq    = @LeaseStuffSeq
      
RETURN

SELECT * FROM  minjun_TACLeaseStuff
SELECT * FROM  minjun_TACLeaseStuffLoc