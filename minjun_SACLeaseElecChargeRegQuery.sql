IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseElecChargeRegQuery' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseElecChargeRegQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ��������_minjun : ��ȸ
 �ۼ��� - '2020-04-28
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROCEDURE dbo.minjun_SACLeaseElecChargeRegQuery
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
    DECLARE  @docHandle      INT
            ,@TenantSeq      INT
            ,@AccYM          NCHAR(6)


    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      


    -- ��ȸ���� �޾ƿ���
    SELECT         
             @TenantSeq     = RTRIM(LTRIM(ISNULL(TenantSeq    ,   0)))
            ,@AccYM         = RTRIM(LTRIM(ISNULL(AccYM        ,  '')))



    FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
    WITH  ( 
            TenantSeq          INT 
           ,AccYM              NCHAR(6)           
           )

    
    -- ��ȸ��� ����ֱ�
    SELECT                                           
             T.CustName                AS  TenantName            --������         
            ,B1.TenantSeq                                        --�������ڵ�
            ,A.AccYM                   AS  ThisYYMM              --�����
            ,A.AccYMFr
            ,A.AccYMTo
            ,B2.LeaseStuffLocName                                --�Ӵ���ġ
            ,(B2.PrivateExtentM + B2.SharingExtentM)            AS  RentArea                                                                --�Ӵ����
            ,A.BfrElecMeter                                      --�����������ħ
            ,A.ThisElecMeter                                     --����跮����ħ
            ,(A.ThisElecMeter - A.BfrElecMeter)     AS  UseAmt   --��뷮
            ,A.UnitCost                                          --KW��ܰ�
            ,A.ElecCharge                                        --�����
            ,D.LeaseContSeq
            ,D.LeaseContSerl
           

            

      FROM minjun_TACLeaseContract                        AS B1     
      LEFT OUTER JOIN minjun_TACLeaseContractDetail       AS D      ON D.CompanySeq        = B1.CompanySeq   
                                                                   AND D.LeaseContSeq      = B1.LeaseContSeq 
      LEFT OUTER JOIN minjun_TACLeaseElecCharge           AS A      ON A.CompanySeq        = D.CompanySeq   
                                                                   AND A.LeaseContSeq      = D.LeaseContSeq 
                                                                   AND A.LeaseContSerl     = D.LeaseContSerl
      LEFT OUTER JOIN minjun_TACLeaseStuffLoc             AS B2     ON B2.CompanySeq       = D.CompanySeq
                                                                   AND B2.LeaseStuffSeq    = D.LeaseStuffSeq
                                                                   AND B2.LeaseStuffSerl   = D.LeaseStuffSerl
      LEFT OUTER JOIN _TDACust                            AS T      ON T.CompanySeq        = B1.CompanySeq
                                                                   AND T.CustSeq           = B1.TenantSeq      



     WHERE  A.CompanySeq    = @CompanySeq
       AND (@TenantSeq                     = 0                    OR  T.CustSeq                  =              @TenantSeq                      )
       AND (@AccYM                         = ''                   OR  A.AccYM                    LIKE           @AccYM              + '%'       )   
 


RETURN