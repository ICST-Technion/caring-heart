export const rangeArr = (start: number, end: number) => [...Array(end - start).keys()].map((i) => i + start)
const _zip = (a: any[], ...b: any[][]) =>
  a.map((el, idx) => [el, ...b.map((arr) => arr[idx])]);

export const zip = <T1, T2>(a: T1[], b: T2[]) => _zip(a, b) as [[T1, T2]]
export const zip3 = <T1, T2, T3>(a: T1[], b: T2[], c: T3[]) =>
  _zip(a, b, c) as [[T1, T2, T3]]
  
export const zip4 = <T1, T2, T3, T4>(a: T1[], b: T2[], c: T3[], d: T4[]) =>
  _zip(a, b, c, d) as [[T1, T2, T3, T4]]
