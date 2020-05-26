# The tool box for informational analysis
## for developer
### Critical issue in `FisherInformation`
Warning:
- This numerical of FIM would extremely deviate from analytical solution, if `pdfx` (`[pdfx,x]=ksdensity(...)`) contains a very small value.
- This problem originates from the fact that `pdfx` is in the denominator

Possible solution or useful resources
- Please refer to [this paper](https://royalsocietypublishing.org/doi/full/10.1098/rsos.160582?fbclid=IwAR0Zq0QNRkuB-8fqRCuoPDdP3X0sX7JAuetYlz-ix8MBtmiAb3TjN7AjWN4) ([pdf](https://royalsocietypublishing.org/doi/pdf/10.1098/rsos.160582)) to fix this issue.
  - see Eq. 2.2 and 2.3: "...handling a small p(s) in the denominator. To overcome this problem p(s) is replaced by its amplitude, which is defined as q2(s) = p(s), thus..."
- There is also a [Python package](https://github.com/csunlab/fisher-information/tree/2db5e287cb1740543afc559094daa6275a93142a) ([and its homepage](https://csun.uic.edu/codes/fisher.html)) for calculating Fisher information. You can compare the result with those from this.

Notes:
- this issue cannot be solved by setting 'NumPoints', or 
> Hsi, 2020-05-26

### Critical issue in running python
- cannot run the python package above
- Adding paths to environments does no help. I still can't execute python command in Terminal. However, it works fine with python interactive
  - to deal with the error using `conda activate`, add the following paths to Path ([link](https://www.jianshu.com/p/cd0096b24b43)).
    - C:\ProgramData\Anaconda3
    - C:\ProgramData\Anaconda3\Scripts
    - C:\ProgramData\Anaconda3\Library\bin

## main function
### `infoAnalysis`

- dependency:
  - `FisherInformation`
  - `ShannonEntropy`
  - `ShannonEntropyPower`


