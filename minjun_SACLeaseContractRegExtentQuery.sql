IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseContractRegExtentQuery' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseContractRegExtentQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ�����_minjun : ������ȸ
 �ۼ��� - '2020-04-22
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseContractRegExtentQuery
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
           ,@LeaseContSeq        INT
  
    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT @LeaseContSeq          = RTRIM(LTRIM(ISNULL(LeaseContSeq          , 0)))
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock2', @xmlFlags)
      WITH ( LeaseContSeq        INT)
    
    -- ����Select
    SELECT	 
            
             B.LeaseStuffLocName                                            --�Ӵ���ġ	
            ,B.PrivateExtentM                                               --�������(m2)
            ,B.SharingExtentM                                               --��������(m2)	
            ,B.PrivateExtentP                                               --�������(��)
            ,B.SharingExtentP                                               --��������(��)	
            ,(B.PrivateExtentM + B.SharingExtentM)   AS   Total_M2
            ,(B.PrivateExtentP + B.SharingExtentP)   AS   Total_
            ,B.Remark                                                       --���		
            ,A.LeaseContSerl                                                --����		
            ,A.LeaseContSeq  
            ,A.LeaseStuffSeq
            ,B.LeaseStuffSerl

				
    FROM    minjun_TACLeaseContractDetail               AS  A   WITH(NOLOCK)
    LEFT OUTER JOIN minjun_TACLeaseStuffLoc             AS  B                   ON B.CompanySeq     =   A.CompanySeq
                                                                               AND B.LeaseStuffSeq  =   A.LeaseStuffSeq
                                                                               AND B.LeaseStuffSerl =   A.LeaseStuffSerl

    WHERE   A.CompanySeq       = @CompanySeq
      AND   A.LeaseContSeq     = @LeaseContSeq
      
RETURN
