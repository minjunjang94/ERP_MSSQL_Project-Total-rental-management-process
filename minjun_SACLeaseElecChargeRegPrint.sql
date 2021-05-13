IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID('minjun_SACLeaseElecChargeRegPrint') AND sysstat & 0xf = 4) /*★*/
    DROP PROCEDURE dbo.minjun_SACLeaseElecChargeRegPrint /*★*/
GO


/*************************************************************************************************    
 설  명 - SP-임대전기료출력_minjun : 출력
 작성일 - '2020-05-04
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/   


CREATE PROCEDURE minjun_SACLeaseElecChargeRegPrint /*★*/    
    @ServiceSeq    INT          = 0 ,  
    @WorkingTag    NVARCHAR(10) = '',  
    @CompanySeq    INT          = 1 ,  
    @LanguageSeq   INT          = 1 ,  
    @UserSeq       INT          = 0 ,  
    @PgmSeq        INT          = 0 ,  
    @IsTransaction BIT          = 0 
AS  
  
    -- 하기 SELECT 구문에 대해 필요에 따라 로직을 수정하여 조회합니다.  

    
      
 --   DECLARE   @CheckCCC             NCHAR(1)  
 --            ,@AccYM                NCHAR(6)    
 --            ,@LeaseContSeq         INT
 --            ,@LeaseContSerl        INT




 --   -- 조회조건 받아오기
 --   SELECT         
 --            @CheckCCC                   = RTRIM(LTRIM(ISNULL(M.CheckCCC                , '')))
 --           ,@AccYM                      = RTRIM(LTRIM(ISNULL(M.AccYM                   , '')))
 --           ,@LeaseContSeq               = RTRIM(LTRIM(ISNULL(M.LeaseContSeq            ,  0)))
 --           ,@LeaseContSerl              = RTRIM(LTRIM(ISNULL(M.LeaseContSerl           ,  0)))


 --FROM  #BIZ_IN_DataBlock1      AS M
                                    
 --          --Master  
 --  SELECT     

 --           T.CustName                AS  TenantName                --임차인
 --          ,A.AccYM                   AS  ThisYYMM                  --해당년월
 --          ,A.BfrElecMeter                                          --전월검침
 --          ,A.ThisElecMeter                                         --당월검침
 --          ,(A.ThisElecMeter - A.BfrElecMeter)     AS  UseAmt       --사용량
 --          ,A.UnitCost                                              --km당 요금
 --          ,A.ElecCharge                                            --전기요금
 --          ,B2.LeaseStuffLocName                                    --임대위치

            
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
          M.TenantName                --임차인
         ,M.ThisYYMM                  --해당년월
         ,M.BfrElecMeter                                          --전월검침
         ,M.ThisElecMeter                                         --당월검침
         ,M.UseAmt       --사용량
         ,M.UnitCost                                              --km당 요금
         ,M.ElecCharge                                            --전기요금
         ,M.LeaseStuffLocName                                    --임대위치
 
        FROM #BIZ_IN_DataBlock1         AS M
        --LEFT OUTER JOIN _TDACust                            AS T      ON T.CompanySeq        = B1.CompanySeq
        --                                                           AND T.CustSeq           = B1.TenantSeq   
RETURN  

