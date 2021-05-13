IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID('minjun_SACLeaseElecChargeRegPrint') AND sysstat & 0xf = 4) /*��*/
    DROP PROCEDURE dbo.minjun_SACLeaseElecChargeRegPrint /*��*/
GO


/*************************************************************************************************    
 ��  �� - SP-�Ӵ���������_minjun : ���
 �ۼ��� - '2020-05-04
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/   


CREATE PROCEDURE minjun_SACLeaseElecChargeRegPrint /*��*/    
    @ServiceSeq    INT          = 0 ,  
    @WorkingTag    NVARCHAR(10) = '',  
    @CompanySeq    INT          = 1 ,  
    @LanguageSeq   INT          = 1 ,  
    @UserSeq       INT          = 0 ,  
    @PgmSeq        INT          = 0 ,  
    @IsTransaction BIT          = 0 
AS  
  
    -- �ϱ� SELECT ������ ���� �ʿ信 ���� ������ �����Ͽ� ��ȸ�մϴ�.  

    
      
 --   DECLARE   @CheckCCC             NCHAR(1)  
 --            ,@AccYM                NCHAR(6)    
 --            ,@LeaseContSeq         INT
 --            ,@LeaseContSerl        INT




 --   -- ��ȸ���� �޾ƿ���
 --   SELECT         
 --            @CheckCCC                   = RTRIM(LTRIM(ISNULL(M.CheckCCC                , '')))
 --           ,@AccYM                      = RTRIM(LTRIM(ISNULL(M.AccYM                   , '')))
 --           ,@LeaseContSeq               = RTRIM(LTRIM(ISNULL(M.LeaseContSeq            ,  0)))
 --           ,@LeaseContSerl              = RTRIM(LTRIM(ISNULL(M.LeaseContSerl           ,  0)))


 --FROM  #BIZ_IN_DataBlock1      AS M
                                    
 --          --Master  
 --  SELECT     

 --           T.CustName                AS  TenantName                --������
 --          ,A.AccYM                   AS  ThisYYMM                  --�ش���
 --          ,A.BfrElecMeter                                          --������ħ
 --          ,A.ThisElecMeter                                         --�����ħ
 --          ,(A.ThisElecMeter - A.BfrElecMeter)     AS  UseAmt       --��뷮
 --          ,A.UnitCost                                              --km�� ���
 --          ,A.ElecCharge                                            --������
 --          ,B2.LeaseStuffLocName                                    --�Ӵ���ġ

            
 --     FROM minjun_TACLeaseContract                        AS B1     
 --     LEFT OUTER JOIN minjun_TACLeaseContractDetail       AS D      ON D.CompanySeq        = B1.CompanySeq   
 --                                                                  AND D.LeaseContSeq      = B1.LeaseContSeq 
 --     LEFT OUTER JOIN minjun_TACLeaseElecCharge           AS A      ON A.CompanySeq        = D.CompanySeq   
 --                                                                  AND A.LeaseContSeq      = D.LeaseContSeq 
 --                                                                  AND A.LeaseContSerl     = D.LeaseContSerl
 --     LEFT OUTER JOIN minjun_TACLeaseStuffLoc             AS B2     ON B2.CompanySeq       = D.CompanySeq
 --                                                                  AND B2.LeaseStuffSeq    = D.LeaseStuffSeq
 --                                                                  AND B2.LeaseStuffSerl   = D.LeaseStuffSerl
 --     LEFT OUTER JOIN _TDACust                            AS T      ON T.CompanySeq        = B1.CompanySeq
 --                                                                  AND T.CustSeq           = B1.TenantSeq     
                                                                   
      
      
      
 --   WHERE       
    
 --    --@AccYM              = A.AccYM
 --    --AND         @LeaseContSeq       = A.LeaseContSeq
 --    --AND         @LeaseContSerl      = A.LeaseContSerl                       

 SELECT 
          M.TenantName                --������
         ,M.ThisYYMM                  --�ش���
         ,M.BfrElecMeter                                          --������ħ
         ,M.ThisElecMeter                                         --�����ħ
         ,M.UseAmt       --��뷮
         ,M.UnitCost                                              --km�� ���
         ,M.ElecCharge                                            --������
         ,M.LeaseStuffLocName                                    --�Ӵ���ġ
 
        FROM #BIZ_IN_DataBlock1         AS M
        --LEFT OUTER JOIN _TDACust                            AS T      ON T.CompanySeq        = B1.CompanySeq
        --                                                           AND T.CustSeq           = B1.TenantSeq   
RETURN  

