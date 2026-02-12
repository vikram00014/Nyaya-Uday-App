class StateInfo {
  final String code;
  final String name;
  final String nameHi;

  const StateInfo({
    required this.code,
    required this.name,
    required this.nameHi,
  });
}

class StateCatalog {
  static const List<StateInfo> all = [
    StateInfo(code: 'AN', name: 'Andaman and Nicobar Islands', nameHi: 'अंडमान और निकोबार द्वीप समूह'),
    StateInfo(code: 'AP', name: 'Andhra Pradesh', nameHi: 'आंध्र प्रदेश'),
    StateInfo(code: 'AR', name: 'Arunachal Pradesh', nameHi: 'अरुणाचल प्रदेश'),
    StateInfo(code: 'AS', name: 'Assam', nameHi: 'असम'),
    StateInfo(code: 'BR', name: 'Bihar', nameHi: 'बिहार'),
    StateInfo(code: 'CH', name: 'Chandigarh', nameHi: 'चंडीगढ़'),
    StateInfo(code: 'CG', name: 'Chhattisgarh', nameHi: 'छत्तीसगढ़'),
    StateInfo(code: 'DN', name: 'Dadra and Nagar Haveli and Daman and Diu', nameHi: 'दादरा और नगर हवेली और दमन और दीव'),
    StateInfo(code: 'DL', name: 'Delhi', nameHi: 'दिल्ली'),
    StateInfo(code: 'GA', name: 'Goa', nameHi: 'गोवा'),
    StateInfo(code: 'GJ', name: 'Gujarat', nameHi: 'गुजरात'),
    StateInfo(code: 'HR', name: 'Haryana', nameHi: 'हरियाणा'),
    StateInfo(code: 'HP', name: 'Himachal Pradesh', nameHi: 'हिमाचल प्रदेश'),
    StateInfo(code: 'JK', name: 'Jammu and Kashmir', nameHi: 'जम्मू और कश्मीर'),
    StateInfo(code: 'JH', name: 'Jharkhand', nameHi: 'झारखंड'),
    StateInfo(code: 'KA', name: 'Karnataka', nameHi: 'कर्नाटक'),
    StateInfo(code: 'KL', name: 'Kerala', nameHi: 'केरल'),
    StateInfo(code: 'LA', name: 'Ladakh', nameHi: 'लद्दाख'),
    StateInfo(code: 'LD', name: 'Lakshadweep', nameHi: 'लक्षद्वीप'),
    StateInfo(code: 'MP', name: 'Madhya Pradesh', nameHi: 'मध्य प्रदेश'),
    StateInfo(code: 'MH', name: 'Maharashtra', nameHi: 'महाराष्ट्र'),
    StateInfo(code: 'MN', name: 'Manipur', nameHi: 'मणिपुर'),
    StateInfo(code: 'ML', name: 'Meghalaya', nameHi: 'मेघालय'),
    StateInfo(code: 'MZ', name: 'Mizoram', nameHi: 'मिजोरम'),
    StateInfo(code: 'NL', name: 'Nagaland', nameHi: 'नागालैंड'),
    StateInfo(code: 'OD', name: 'Odisha', nameHi: 'ओडिशा'),
    StateInfo(code: 'PY', name: 'Puducherry', nameHi: 'पुदुच्चेरी'),
    StateInfo(code: 'PB', name: 'Punjab', nameHi: 'पंजाब'),
    StateInfo(code: 'RJ', name: 'Rajasthan', nameHi: 'राजस्थान'),
    StateInfo(code: 'SK', name: 'Sikkim', nameHi: 'सिक्किम'),
    StateInfo(code: 'TN', name: 'Tamil Nadu', nameHi: 'तमिलनाडु'),
    StateInfo(code: 'TG', name: 'Telangana', nameHi: 'तेलंगाना'),
    StateInfo(code: 'TR', name: 'Tripura', nameHi: 'त्रिपुरा'),
    StateInfo(code: 'UP', name: 'Uttar Pradesh', nameHi: 'उत्तर प्रदेश'),
    StateInfo(code: 'UK', name: 'Uttarakhand', nameHi: 'उत्तराखंड'),
    StateInfo(code: 'WB', name: 'West Bengal', nameHi: 'पश्चिम बंगाल'),
  ];

  static final Map<String, StateInfo> _byCode = {
    for (final state in all) state.code: state,
  };

  static final Map<String, String> _aliases = {
    'NCT OF DELHI': 'DL',
    'ORISSA': 'OD',
    'UTTARANCHAL': 'UK',
  };

  static StateInfo? tryResolve(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      return null;
    }

    final upper = value.toUpperCase();
    if (_byCode.containsKey(upper)) {
      return _byCode[upper];
    }

    final aliasCode = _aliases[upper];
    if (aliasCode != null) {
      return _byCode[aliasCode];
    }

    for (final state in all) {
      if (state.name.toUpperCase() == upper || state.nameHi.toUpperCase() == upper) {
        return state;
      }
    }

    return null;
  }

  static String normalizeCode(String raw) {
    return tryResolve(raw)?.code ?? raw.trim().toUpperCase();
  }

  static String displayName(String raw) {
    return tryResolve(raw)?.name ?? raw.trim();
  }
}
