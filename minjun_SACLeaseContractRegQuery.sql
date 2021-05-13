IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseContractRegQuery' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseContractRegQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ�����_minjun : ��ȸ
 �ۼ��� - '2020-04-22
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseContractRegQuery
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
           ,@LeaseContSeq   INT
  

    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT   @LeaseContSeq       = ISNULL(LeaseContSeq       ,  0)
             


      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH  (LeaseContSeq        INT --�ʵ� ��� ������ Ÿ���� ������� �Ѵ�.
            )
    


    -- ����Select
    SELECT   

             A.LeaseContNo
            ,A.ContractDate
            ,A.LeaseContSeq
            ,B.Area
            ,B.LeaseStuffName
            ,C.CustName           AS TenantName
            ,A.ChargePerson
            ,A.ChargePersonTel
            ,A.ChargePersonEmail
            ,C.BizNo
            ,C.Owner
            ,C.BizAddr            AS Address
            ,A.UMContractType 
            ,A.UMPayMonthType     
            ,E.MinorName            AS  UMPayMonthTypeName
            ,A.LeaseDateFr
            ,A.LeaseDateTo
            ,A.ParkingCnt
            ,A.ManageEmp
            ,A.Purpose
            ,A.SpecialNote
            ,A.LeaseContName
            ,D.LeaseStuffSeq
            ,D.TenantSeq
			,A.FileSeq


     FROM	            minjun_TACLeaseContract		            AS A	        WITH(NOLOCK)
     LEFT OUTER JOIN    minjun_TACLeaseStuff                    AS B            ON  B.CompanySeq        = A.CompanySeq
                                                                               AND  B.LeaseStuffSeq     = A.LeaseStuffSeq        
     LEFT OUTER JOIN    _TDACust                                AS C            ON  C.CompanySeq        = A.CompanySeq 
                                                                               AND  C.CustSeq           = A.TenantSeq
     LEFT OUTER JOIN    minjun_TACLeaseContract                 AS D            ON  D.CompanySeq        = A.CompanySeq 
                                                                               AND  D.LeaseContSeq      = A.LeaseContSeq                             
     LEFT OUTER JOIN    _TDAUMinor                              AS E            ON  E.CompanySeq        = D.CompanySeq
                                                                               AND  E.MinorSeq          = D.UMPayMonthType

     WHERE  A.CompanySeq          = @CompanySeq
       AND  A.LeaseContSeq        = @LeaseContSeq
  
RETURN