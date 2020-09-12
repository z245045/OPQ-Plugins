# -*- coding: utf-8 -*- 
import os

from chatPlugin import train_eval
from chatPlugin.datapreprocess import preprocess
from chatPlugin.QA_data import QA_test
from chatPlugin.config import Config



def chat(input_sentence):
    
    opt = Config()
    opt.use_QA_first = False

    searcher, sos, eos, unknown, word2ix, ix2word = train_eval.test(opt)

    if os.path.isfile(opt.corpus_data_path) == False:
        preprocess()

    if opt.use_QA_first:
        query_res = QA_test.match(input_sentence)
        if(query_res == tuple()):
            output_words = train_eval.output_answer(input_sentence, searcher, sos, eos, unknown, opt, word2ix, ix2word)
        else:
            output_words = "您是不是要找以下问题: " + query_res[1] + '，您可以尝试这样: ' + query_res[2]
    else:
        output_words = train_eval.output_answer(input_sentence, searcher, sos, eos, unknown, opt, word2ix, ix2word)
    print('BOT > ', output_words)
    return output_words
    
if __name__ == "__main__":
    chat("你好啊！")
