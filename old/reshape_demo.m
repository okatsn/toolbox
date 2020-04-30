%% reshape

ProcessedSlipMatrix=p(:)';%若含有複數則使用.'%以上兩行是為了把矩陣變成一維，以利等一下做平均
%ProcessedSlipMatrix=reshape(p,1,[]);%另外一個轉成一維陣列的等效方法(轉成一列，[]代表行數不管)
%A(:) is all the elements of A, regarded as a single column.