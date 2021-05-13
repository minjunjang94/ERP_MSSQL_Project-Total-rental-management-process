IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseStuffRegCheck' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseStuffRegCheck
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ빰�ǵ��_minjun : üũ               
 �ۼ��� - '2020-04-21
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseStuffRegCheck
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
           ,@Date           NCHAR(8)        -- Date
           ,@TblName        NVARCHAR(MAX)   -- Table��
           ,@SeqName        NVARCHAR(MAX)   -- Table Ű�� ��
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName    = N'minjun_TACLeaseStuff'
           ,@SeqName    = N'LeaseStuffSeq'
    
    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #minjun_TACLeaseStuff_ (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock1', '#minjun_TACLeaseStuff_' 
    --_SCAOpenXmlToTemp ���� �ӽ� sp�� ����

    IF @@ERROR <> 0 RETURN
    
    




     EXEC dbo._SCOMMessage   @MessageType    OUTPUT
                            ,@Status         OUTPUT
                            ,@Results        OUTPUT
                            ,8                      -- SELECT * FROM _TCAMessageLanguage WITH(NOLOCK) WHERE LanguageSeq = 1 AND Message LIKE '%����%'
                            ,@LanguageSeq
                            ,0, '�Ӵ빰����'                   -- SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE '%%'
                            ,0, '�Ӵ�����'              --SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE '%%'     UPDATE  #BIZ_OUT_DataBlock1
     UPDATE #minjun_TACLeaseStuff_
        SET  Result          = @Results
            ,MessageType     = @MessageType
            ,Status          = @Status
       FROM  #minjun_TACLeaseStuff_                  AS M
       JOIN  minjun_TACLeaseContract                 AS B       ON B.CompanySeq         = @CompanySeq
                                                               AND B.LeaseStuffSeq      = M.LeaseStuffSeq
      WHERE  M.WorkingTag IN('D')
        AND  M.Status = 0
        AND  M.LeaseStuffSeq = B.LeaseStuffSeq






    -- ä���ؾ� �ϴ� ������ �� Ȯ��
    SELECT @Count = COUNT(1) FROM #minjun_TACLeaseStuff_ WHERE WorkingTag = 'A' AND Status = 0 
     
    -- ä��
    IF @Count > 0
    BEGIN
        -- �����ڵ�ä�� : ���̺��� �ý��ۿ��� Max������ �ڵ� ä���� ���� �����Ͽ� ä��
        EXEC @Seq = dbo._SCOMCreateSeq @CompanySeq, @TblName, @SeqName, @Count
        
        UPDATE  #minjun_TACLeaseStuff_
           SET  LeaseStuffSeq = @Seq + DataSeq
         WHERE  WorkingTag  = 'A'
           AND  Status      = 0
        
  --     -- �ܺι�ȣ ä���� ���� ���ڰ�
  --     SELECT @Date = CONVERT(NVARCHAR(8), GETDATE(), 112)        
  --     
  --     -- �ܺι�ȣä�� : ������ �ܺ�Ű�������ǵ�� ȭ�鿡�� ���ǵ� ä����Ģ���� ä��
  --     EXEC dbo._SCOMCreateNo 'HR', @TblName, @CompanySeq, '', @Date, @MaxNo OUTPUT
  --     
  --     UPDATE  #minjun_TACLeaseStuff_
  --        SET  BookNo = @MaxNo
  --      WHERE  WorkingTag  = 'A'
  --        AND  Status      = 0
   END
   
    SELECT * FROM #minjun_TACLeaseStuff_
    
RETURN