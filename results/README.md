# Council-Code Results Archive

원탁회의 결과가 JSON으로 저장됩니다.

- 파일명: `YYYYMMDD-HHMMSS-{topic_slug}.json`
- 용도: 과거 결론 재참조, 반복 주제 감지, 의사결정 히스토리

## 검색 예시

```bash
# 특정 주제 검색
grep -l "다크모드" results/*.json

# 최근 1주 결론
ls -t results/*.json | head -20

# 특정 페르소나가 참여한 회의만
jq 'select(.personas_summoned | contains(["security"]))' results/*.json
```
