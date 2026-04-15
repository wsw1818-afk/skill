# Council-Code Execution Logs

이 디렉토리는 council-code 스킬의 실행 로그가 append-only로 저장됩니다.

- 파일명: `YYYY-MM-DD.jsonl`
- 형식: JSONL (각 줄이 독립 JSON 이벤트)
- 용도: 사용 패턴 분석, 페르소나 튜닝, 실패 감지

## 분석 예시

```bash
# 오늘 호출 횟수
wc -l logs/$(date +%Y-%m-%d).jsonl

# 가장 많이 소집된 페르소나
cat logs/*.jsonl | jq -r '.personas[]' | sort | uniq -c | sort -rn

# 평균 소요 시간
cat logs/*.jsonl | jq '.duration_ms' | awk '{s+=$1; n++} END{print s/n/1000 "s"}'
```
