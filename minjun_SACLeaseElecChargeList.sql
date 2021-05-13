IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseElecChargeList' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseElecChargeList
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ⱓ���������ȸ_minjun : ��ȸ
 �ۼ��� - '2020-05-07
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROCEDURE dbo.minjun_SACLeaseElecChargeList
    @ServiceSeq    INT          = 0 ,   -- ���� �����ڵ�
    @WorkingTag    NVARCHAR(10) = '',   -- WorkingTag
    @CompanySeq    INT          = 1 ,   -- ���� �����ڵ�
    @LanguageSeq   INT          = 1 ,   -- ��� �����ڵ�
    @UserSeq       INT          = 0 ,   -- ����� �����ڵ�
    @PgmSeq        INT          = 0 ,   -- ���α׷� �����ڵ�
    @IsTransaction BIT          = 0     -- Ʈ������ ����
AS
	-- ��������
    DECLARE         
                     @AccYMFr           NCHAR(6)
                    ,@AccYMTo           NCHAR(6)
                    ,@TenantSeq         INT
                    ,@AccYM             NCHAR(6)



           

    -- ��ȸ���� �޾ƿ���
    SELECT  @AccYMFr       = RTRIM(LTRIM(ISNULL(AccYMFr       , '')))
           ,@AccYMTo       = RTRIM(LTRIM(ISNULL(AccYMTo       , '')))
           ,@TenantSeq     = RTRIM(LTRIM(ISNULL(TenantSeq     , 0)))



      FROM  #BIZ_IN_DataBlock1      AS M

	/*************************************************
	-- #Title : �����
	*************************************************/
	CREATE TABLE #Title(
        TitleName   NVARCHAR(MAX)
      , TitleSeq    INT
      , TitleName2  NVARCHAR(MAX)
      , TitleSeq2   INT
      , ColIDX      INT IDENTITY(0, 1)
    )

    INSERT INTO #Title(
        TitleName
      , TitleSeq
      , TitleName2
      , TitleSeq2
	)   
    SELECT DISTINCT
           LEFT(CONVERT(CHAR(6), Solar, 112), 4) + '-' + RIGHT(CONVERT(CHAR(6), Solar, 112), 2) AS TitleName
         , CONVERT(CHAR(6), Solar, 112) AS TitleSeq
         , '��뷮' AS TitleName2
         , 1 AS TitleSeq2
      FROM _TCOMCalendar AS A
     WHERE CONVERT(NCHAR(6), Solar, 112) BETWEEN @AccYMFr AND @AccYMTo     

    UNION ALL

    SELECT DISTINCT
           LEFT(CONVERT(CHAR(6), Solar, 112), 4) + '-' + RIGHT(CONVERT(CHAR(6), Solar, 112), 2) AS TitleName
         , CONVERT(CHAR(6), Solar, 112) AS TitleSeq
         , '�����' AS TitleName2
         , 2 AS TitleSeq2
      FROM _TCOMCalendar AS A
     WHERE CONVERT(NCHAR(6), Solar, 112) BETWEEN @AccYMFr AND @AccYMTo
     ORDER BY TitleSeq, TitleSeq2





	/*************************************************
	-- #FixCol : ������
	*************************************************/
	CREATE TABLE #FixCol(
		 RowIDX		        INT IDENTITY(0, 1)
	    ,AccYM              NCHAR(6) 
        ,TenantName         NVARCHAR(100)
        ,UseAmt             DECIMAL(19,5)
        ,ElecCharge         DECIMAL(19,5)
       
       
	)

	INSERT INTO #FixCol(
        AccYM      
       ,TenantName 
       ,UseAmt
       ,ElecCharge

       
	   
    ) 
    SELECT   
              MIN(LEFT(B.ContractDate, 6))                  AS      ContractDate     
             ,T.CustName                                    AS      TenantName                                
             ,sum((A.ThisElecMeter - A.BfrElecMeter))       AS      UseAmt   
             ,sum(A.ElecCharge)         AS ElecCharge


      FROM  minjun_TACLeaseElecCharge               AS A 
      LEFT OUTER JOIN minjun_TACLeaseContract       AS B            ON B.CompanySeq        = A.CompanySeq
                                                                   AND B.LeaseContSeq      = A.LeaseContSeq  
      LEFT OUTER JOIN minjun_TACLeaseContractDetail AS C            ON C.CompanySeq        = A.CompanySeq   
                                                                   AND C.LeaseContSeq      = A.LeaseContSeq 
                                                                   AND C.LeaseContSerl     = A.LeaseContSerl
      LEFT OUTER JOIN _TDACust                      AS T            ON T.CompanySeq        = B.CompanySeq
                                                                   AND T.CustSeq           = B.TenantSeq   
	 WHERE  A.CompanySeq    = @CompanySeq
       AND  A.AccYM Between @AccYMFr AND @AccYMTo 
       AND  (@TenantSeq    = 0        OR  T.CustSeq          = @TenantSeq      )

     GROUP BY  T.CustName


	/*************************************************
	-- #Value ������
	*************************************************/
	CREATE TABLE #Value(
        ColIDX          INT
       ,RowIDX          INT
       ,Value           DECIMAL(19,5)
    )




    -- Group by ����, �Ǿ�ǰ
    -- Sum (������)

    select
            T.CustName                                   AS  TenantName    
           ,sum((A.ThisElecMeter - A.BfrElecMeter))      AS  UseAmt
           ,sum(A.ElecCharge)                            AS  ElecCharge         --�����
           ,MIN(LEFT(B.ContractDate, 6))                 AS  ContractDate
           ,A.AccYM                                      AS  AccYM



    into #TEMP_data

      FROM  minjun_TACLeaseElecCharge               AS A 
      LEFT OUTER JOIN minjun_TACLeaseContract       AS B            ON B.CompanySeq        = A.CompanySeq
                                                                   AND B.LeaseContSeq      = A.LeaseContSeq  
      LEFT OUTER JOIN _TDACust                      AS T            ON T.CompanySeq        = B.CompanySeq
                                                                   AND T.CustSeq           = B.TenantSeq  

    where A.CompanySeq         = @CompanySeq
      AND  A.AccYM Between @AccYMFr AND @AccYMTo 
       
    GROUP BY T.CustName, A.AccYM




	INSERT INTO #Value (
        ColIDX
       ,RowIDX
       ,Value
    )
	SELECT  X.ColIDX
           ,Y.RowIDX
           ,CASE 
                WHEN X.TitleSeq2 = 1 THEN A.UseAmt
                WHEN X.TitleSeq2 = 2 THEN A.ElecCharge 
            END AS Value



      FROM  #TEMP_data              AS A  WITH(NOLOCK)
            JOIN #Title             AS X  WITH(NOLOCK)  ON  X.TitleSeq          = A.AccYM
            JOIN #FixCol            AS Y  WITH(NOLOCK)  ON  Y.TenantName        = A.TenantName
     --WHERE  A.CompanySeq    = @CompanySeq
        

	/*************************************************
	-- ��ȸ��� SELECT
	*************************************************/
    SELECT * FROM #Title
    SELECT * FROM #FixCol
    SELECT * FROM #Value

RETURN  
/******************************************************************************************/  
GO