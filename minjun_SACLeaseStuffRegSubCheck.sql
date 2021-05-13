IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseStuffRegSubCheck' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseStuffRegSubCheck
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ빰�ǵ��_minjun : ����üũ
 �ۼ��� - '2020-04-21
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseStuffRegSubCheck
     @xmlDocument    NVARCHAR(MAX)          -- Xml������
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- ���� ��ȣ
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- ȸ�� ��ȣ
    ,@LanguageSeq    INT            = 1     -- ��� ��ȣ
    ,@UserSeq        INT            = 0     -- ����� ��ȣ
    ,@PgmSeq         INT            = 0     -- ���α׷� ��ȣ
 AS    
    DECLARE @MessageType    INT             -- �����޽��� Ÿ��
           ,@Status         INT             -- ���º���
           ,@Results        NVARCHAR(250)   -- �������
           ,@Count          INT             -- ä�������� Row ��
           ,@Seq            INT             -- Seq
           ,@MaxNo          NVARCHAR(20)    -- ä�� ������ �ִ� No
           ,@MaxSerl        INT             -- Serl�� �ִ밪
           ,@TblName        NVARCHAR(MAX)   -- Table��
           ,@SeqName        NVARCHAR(MAX)   -- Seq��
           ,@SerlName       NVARCHAR(MAX)   -- Serl��
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName    = N'minjun_TACLeaseStuffLoc'
           ,@SeqName    = N'LeaseStuffSeq'
           ,@SerlName   = N'LeaseStuffSerl'
           ,@MaxSerl    = 0
    
    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #minjun_TACLeaseStuffLoc_ (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock2', '#minjun_TACLeaseStuffLoc_' 
    
    IF @@ERROR <> 0 RETURN



         EXEC dbo._SCOMMessage   @MessageType    OUTPUT
                            ,@Status         OUTPUT
                            ,@Results        OUTPUT
                            ,8                      -- SELECT * FROM _TCAMessageLanguage WITH(NOLOCK) WHERE LanguageSeq = 1 AND Message LIKE '%����%'
                            ,@LanguageSeq
                            ,0, '�Ӵ빰����'                   -- SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE '%%'
                            ,0, '�Ӵ�����'              --SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE '%%'     UPDATE  #BIZ_OUT_DataBlock1
     UPDATE #minjun_TACLeaseStuffLoc_
        SET  Result          = @Results
            ,MessageType     = @MessageType
            ,Status          = @Status
       FROM  #minjun_TACLeaseStuffLoc_               AS M
       JOIN  minjun_TACLeaseContractDetail           AS B       ON B.CompanySeq         = @CompanySeq
                                                               AND B.LeaseStuffSeq      = M.LeaseStuffSeq
                                                               AND B.LeaseStuffSerl     = M.LeaseStuffSerl
      WHERE  M.WorkingTag IN('D')
        AND  M.Status = 0
        AND  M.LeaseStuffSeq = B.LeaseStuffSeq








    -- ä���ؾ� �ϴ� ������ �� Ȯ��
    SELECT @Count = COUNT(1) FROM #minjun_TACLeaseStuffLoc_ WHERE WorkingTag = 'A' AND Status = 0 
     
    -- ä��
    IF @Count > 0
    BEGIN
        -- Serl Max�� ��������
        SELECT  @MaxSerl    = MAX(ISNULL(A.LeaseStuffSerl, 0))
          FROM  #minjun_TACLeaseStuffLoc_                              AS M
                LEFT OUTER JOIN minjun_TACLeaseStuffLoc     AS A  WITH(NOLOCK)  ON  A.CompanySeq          = @CompanySeq
                                                                                AND A.LeaseStuffSeq       = M.LeaseStuffSeq
         WHERE  M.WorkingTag IN('A')
           AND  M.Status = 0                    
        
        UPDATE  #minjun_TACLeaseStuffLoc_
           SET  LeaseStuffSerl = @MaxSerl + DataSeq
         WHERE  WorkingTag  = 'A'
           AND  Status      = 0
    END
   
    SELECT * FROM #minjun_TACLeaseStuffLoc_
    
RETURN